-- Set the journal mode to Write-Ahead Logging for concurrency
PRAGMA journal_mode = WAL;

-- Set synchronous mode to NORMAL for performance and data safety balance
PRAGMA synchronous = NORMAL;

-- Set busy timeout to 5 seconds to avoid "database is locked" errors
PRAGMA busy_timeout = 5000;

-- Set cache size to 20MB for faster data access
PRAGMA cache_size = -20000;

-- Enable foreign key constraint enforcement
PRAGMA foreign_keys = ON;

-- Enable auto vacuuming and set it to incremental mode for gradual space reclaiming
PRAGMA auto_vacuum = INCREMENTAL;

-- Store temporary tables and data in memory for better performance
PRAGMA temp_store = MEMORY;

-- Set the mmap_size to 2GB for faster read/write access using memory-mapped I/O
PRAGMA mmap_size = 2147483648;

-- Set the page size to 8KB for balanced memory usage and performance
PRAGMA page_size = 8192;

-- (c) https://briandouglas.ie/sqlite-defaults/
-- (c) https://dev.to/briandouglasie/sensible-sqlite-defaults-5ei7
