# Multi-Threaded Indexer Development Plan

## Step 0 – Decisions & Scope
- Target concurrency model: in-process worker threads driven by `Thread::Queue`. All DB/cache writes remain single-threaded via a coordinator queue.
- Maintain a feature flag (`setting/admin/index/parallel_workers`, default `0`) and optional CLI override (`index.pl --threads N`).
- Initial scope: parallelise text indexing only; image/video/file-specific indexers continue to run serially or are enqueued as separate jobs later.

## Step 1 – Refactor for Thread Safety
1. Extract pure helpers:
   - Move hashing/trim logic from `IndexFile`/`IndexTextFile` into functions that accept explicit arguments and return results without touching globals.
   - Audit all `state` variables in `utils.pl`/`index_file.pl`/`index_text_file.pl`; provide accessor wrappers that return thread-local copies (e.g., using `%threadLocal` hashes keyed by `threads::tid`).
2. Centralise logging so multiple threads can log safely (e.g., wrap `WriteLog` with a mutex or send messages to the main thread).

## Step 2 – Job Abstraction
1. Define a `struct` (hashref) representing an indexing job: `{ file => $path, type => 'text', flags => { ... } }`.
2. Build a `dispatch_text_index($job)` helper that performs the pure steps (hashing, parsing, token detection) and returns a bundle of “mutations” (`[{ op => 'DBAddItem', args => [...] }, ...]`).
3. For serial fallback, have the dispatcher immediately execute the mutations synchronously (preserving current behaviour).

## Step 3 – Coordinator & Queues
1. Create a `Thread::Queue` for jobs and a second queue for mutations back to the main thread.
2. Main thread responsibilities:
   - Enqueue jobs discovered by `MakeIndex` / CLI args.
   - Drain the mutation queue and execute DB/cache operations via existing `DB*` helpers.
   - Track outstanding workers; shut down cleanly when queues empty.
3. Worker thread responsibilities:
   - Pull jobs, run the dispatcher, push mutations, catch errors, and report failures (e.g., push `{ op => 'error', file => ..., error => ... }`).

## Step 4 – Database Layer Changes
1. Ensure `SqliteQuery` supports serialized access (e.g., wrap shell invocations in a mutex or migrate to DBI so we can hold a connection in the main thread).
2. Add batching support in the coordinator: collect mutations into transaction-sized groups (e.g., commit every N operations or per job).
3. Implement retry logic for `SQLITE_BUSY` by backing off and re-enqueueing the mutation block.

## Step 5 – Configuration & CLI Wiring
1. Add new setting files: `default/setting/admin/index/parallel_workers` (default `0`).
2. Update `index.pl` argument parser to accept `--threads=N`; when provided, override the setting for that run.
3. Document new switches in `doc/settings.md` and `AGENTS.md` including safe values (start with `1-2`, caution about CPU/IO constraints).

## Step 6 – Testing Strategy
1. Unit tests:
   - Introduce a small corpus with known outputs; run serial vs. threaded to confirm identical DB state.
   - Add regression tests for error propagation (e.g., jobs that throw exceptions, DB lock contention).
2. Integration script:
   - Build a `test/parallel_index.sh` (or extend `python3 test/test.py`) to run `hike index` with different worker counts on a fixture dataset.
3. Stress testing:
   - Manual script generating many synthetic text files; measure throughput with `1/2/4` workers, check logs for warnings.

## Step 7 – Rollout Plan
1. Phase 1: ship serial refactor + job abstraction with `parallel_workers` hardwired to `0`; confirm no behavioural change.
2. Phase 2: enable the queue + worker threads, but keep setting default `0`. Provide docs encouraging opt-in for test environments.
3. Phase 3: gather feedback, tune batch size / queue limits, and only then consider increasing the default (if at all).

## Step 8 – Follow-up Enhancements (Nice-to-have)
- Extend worker queue to handle image/video jobs; each job type defines its own dispatcher/mutation builder.
- Investigate job persistence (e.g., resume interrupted indexing) using on-disk queue snapshots.
- Add metrics endpoints or log summaries (jobs per second, average DB batch size) for operational visibility.
