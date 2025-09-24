# index.pl Optimization Plan

## Goals
- Reduce the wall-clock time for `hike index` and direct `index.pl` invocations.
- Preserve existing indexing semantics (cache/flush behaviour and logging).
- Keep optional indexers (image, video, language-specific) working without regressions.

## Phase 1 – Baseline & Safeguards
- Capture current runtime for `hike index --all` on representative content; log CPU, I/O, and DB usage.
- Add lightweight timing around major stages (discovery, text indexing, media passes, sweeps).
- Define the regression checks to re-run after each change (at minimum `python3 test/test.py` plus a smoke `hike index --all`).

## Phase 2 – Remove Obvious Stalls
- Strip debugging `sleep` calls and redundant `print length($html)` statements in `IndexHtmlFile`.
- Audit other helpers for unconditional delays or verbose logging and guard them behind a debug flag.
- Ensure progress logging remains concise to avoid excessive stdout churn.

## Phase 3 – Streamline File Discovery
- Replace the backtick `find` calls with a streaming iterator so indexing can begin before the entire list is materialised.
- Skip discovery work for modules that are disabled via config.
- Only compute collection sizes when needed for progress percentages; otherwise iterate lazily.

## Phase 4 – Optimise Per-File Indexing Path
- Profile `IndexTextFile` hotspots (token parsing, DB writes) and batch related database operations inside transactions.
- Reuse prepared statements or cached handles within the DB helper layer to reduce connection overhead.
- Double-check the cache short-circuit (`IsFileAlreadyIndexed`) so unchanged files exit early with minimal work.

## Phase 5 – Optional Parallelism Evaluation
- Audit thread safety: SQLite access, global caches, and `state` variables currently assume single-threaded execution.
- If parallelism is still required, prefer process-based workers with isolated DB handles or a task queue instead of enabling the unfinished threads path.
- Gate any parallel mode behind a configuration flag, defaulting to serial execution for safe rollback.

## Phase 6 – Clean-up & Documentation
- Update developer docs with the revised indexing flow and performance tuning knobs.
- Capture profiling commands and benchmarking expectations for future contributors.
- Consider adding coarse-grained timing checks to CI to detect future performance regressions.
