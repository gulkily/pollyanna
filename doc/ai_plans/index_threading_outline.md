# Multi-Threaded Indexing Outline

## Current State
- `IndexFile` hardcodes `$useThreads = 0`; the threaded branch simply wraps `IndexTextFile` inside `threads->create` but shares global state and joins immediately.
- DB helpers (e.g., `DBAddItem`, `SqliteQuery`) use a shared SQLite connection invoked via shell commands, expecting single-threaded access.
- Utilities rely on global `state` caches (`%memoFileHash`, etc.) that are not synchronised outside the main thread.
- Worker modules (`index_text_file.pl`, `index_image_file.pl`) interact with caches and config files in place; no locking.

## Goals
1. Enable concurrent indexing of independent files while preserving correctness.
2. Avoid rewriting the entire pipeline; isolate concurrency to a well-defined layer.
3. Maintain compatibility with existing configuration (serial mode remains default).

## Phase 1 – Audit & Baseline
- Instrument current indexing run to capture hotspots (hashing, DB writes, thumbnail generation).
- Identify resources that must remain single-writer (SQLite DB, cache files in `cache/`, log files).
- Decide on concurrency model: Perl threads vs. forked workers vs. external job queue; prefer processes if threading remains risky due to XS modules.

## Phase 2 – Extract Thread-Safe Core
- Refactor `IndexFile`/`IndexTextFile` so pure computation (hashing, parsing) happens in pure functions with thread-local data.
- Ensure per-file state (`%indexMessageLog`, temporary buffers) lives on the stack, not in package globals.
- Wrap shared caches (`%memoFileHash`, `state` variables) with accessors that either use thread-local copies or synchronise via locks.

## Phase 3 – Database & Cache Strategy
- Move SQLite access behind a queue: main thread owns the writer; worker threads push DB intents (e.g., `DBAddItem`, `DBAddLabel`) onto a synchronized queue.
- Alternatively, switch to a connection pool with WAL mode enabled and wrap write batches in transactions; ensure PRAGMA `busy_timeout` is set.
- Serialise file writes (`PutFile`, `PutConfig`) through a central dispatcher to avoid clobbering shared files.

## Phase 4 – Job Scheduling Layer
- Introduce a worker pool (e.g., `threads->create` with a shared `Thread::Queue`) where main thread enqueues file paths.
- Each worker performs CPU-bound steps and posts DB/cache actions back to the coordinator.
- Ensure graceful shutdown by enqueuing poison pills and flushing outstanding DB jobs.

## Phase 5 – Error Handling & Retries
- Propagate worker exceptions to the main thread; maintain per-file status for resumability.
- Implement retry logic for transient SQLite locks; log irrecoverable errors with enough metadata to re-run a file serially.

## Phase 6 – Configuration & Rollout
- Add `setting/admin/index/parallel_workers` (default 0) controlling worker count.
- Update CLI (`index.pl --threads N`) to override config for experimentation.
- Document operational guidelines (when to enable, resource requirements, interaction with thumbnail generation).

## Phase 7 – Testing & Monitoring
- Create regression tests that index a miniature corpus in parallel and validate DB contents.
- Stress-test with large binaries and simulated DB locks to ensure the dispatcher behaves.
- Add metrics/logging summarising queue depth, worker runtimes, and DB latency.

## Future Enhancements
- Opportunistically batch DB writes within workers if we move to per-thread connections.
- Explore splitting indexing by file type (text vs. media) into dedicated worker pools.
- Evaluate using external job runners (e.g., `Parallel::ForkManager`, systemd queue) if in-process threading proves unstable.
