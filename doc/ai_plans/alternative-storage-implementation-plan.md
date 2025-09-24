# Alternative Storage Implementation Plan: sqlite-storage Theme

## Overview

This document outlines the implementation of a new storage theme called `sqlite-storage` that replaces the traditional html/txt file-based storage with a dedicated SQLite database file. This theme will store all item content directly in SQLite while maintaining full compatibility with the existing Pollyanna architecture.

**CRITICAL DESIGN PRINCIPLE**: This implementation creates item-specific storage functions (`GetItem`, `PutItem`, etc.) rather than overriding generic file I/O functions (`GetFile`, `PutFile`) which are used throughout the codebase for templates, configurations, and other non-content files.

## Architecture Design

### Current Storage Model
- **Files**: Items stored as individual `.txt` files in `html/txt/` directory
- **Database**: Metadata and relationships in `cache/b/index.sqlite3`
- **Cache**: Processed content cached in `cache/` directory
- **File I/O**: Generic `GetFile()`/`PutFile()` used for all file operations

### New sqlite-storage Model
- **Files**: Eliminated - no files in `html/txt/`
- **Database**: All content AND metadata in separate `storage/content.sqlite3`
- **Cache**: Maintained using existing cache system (file or sqlite-cache theme)
- **File I/O**: Generic functions unchanged; new item-specific functions created

## Implementation Strategy

### 1. Theme Structure

```
/default/theme/sqlite-storage/
├── template/
│   ├── perl/
│   │   ├── item_storage.pl   # NEW: Item-specific storage functions
│   │   └── database.pl       # Override database operations if needed
│   └── php/
│       └── item_storage.php  # PHP item storage operations
├── schema.sql                # Database schema for content storage
└── README.md                 # Theme documentation
```

### 2. Database Schema Design

Create a dedicated content database with the following structure:

```sql
-- storage/content.sqlite3

CREATE TABLE items (
    hash TEXT PRIMARY KEY,           -- SHA1 hash (same as filename)
    content TEXT NOT NULL,           -- Raw file content
    content_type TEXT DEFAULT 'text/plain',
    file_size INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    version INTEGER DEFAULT 1,
    checksum TEXT,                   -- Redundant hash verification
    encoding TEXT DEFAULT 'utf8',
    compressed INTEGER DEFAULT 0     -- Future: compression flag
);

CREATE TABLE item_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hash TEXT NOT NULL,
    content TEXT NOT NULL,
    version INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    operation TEXT DEFAULT 'update', -- 'create', 'update', 'delete'
    FOREIGN KEY (hash) REFERENCES items(hash)
);

-- Indexes for performance
CREATE INDEX idx_items_created_at ON items(created_at);
CREATE INDEX idx_items_updated_at ON items(updated_at);
CREATE INDEX idx_history_hash ON item_history(hash);
CREATE INDEX idx_history_created_at ON item_history(created_at);

-- Migration tracking
CREATE TABLE migration_status (
    file_path TEXT PRIMARY KEY,
    migrated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    original_size INTEGER,
    status TEXT DEFAULT 'completed'
);
```

### 3. Core Function Overrides

#### 3.1 File Operations (`file.pl`)

```perl
#!/usr/bin/perl -T

use strict;
use 5.010;
use warnings;
use utf8;
use DBI;
use DBD::SQLite;
use Digest::SHA1 qw(sha1_hex);
use Encode qw(encode_utf8 decode_utf8);

my $storage_dbh;

sub InitializeStorageDb {
    my $storageDir = GetDir('storage');
    if (!-d $storageDir) {
        require File::Path;
        File::Path::make_path($storageDir) or die "Failed to create storage directory: $!";
    }
    
    my $dbFile = "$storageDir/content.sqlite3";
    $storage_dbh = DBI->connect(
        "dbi:SQLite:dbname=$dbFile",
        "", "",
        {
            RaiseError => 1,
            AutoCommit => 1,
            sqlite_busy_timeout => 10000,
            sqlite_unicode => 1
        }
    ) or die "Cannot connect to storage database: $DBI::errstr";
    
    # Initialize schema
    my $schema = GetTemplate('sqlite-storage/schema.sql');
    $storage_dbh->do($schema) or die $storage_dbh->errstr;
}

sub GetFile { # $filename ; returns file content from SQLite
    my $filename = shift;
    chomp $filename;
    
    state $initialized;
    if (!$initialized) {
        InitializeStorageDb();
        $initialized = 1;
    }
    
    # Extract hash from filename
    my $hash = ExtractHashFromFilename($filename);
    if (!$hash) {
        WriteLog("GetFile: Could not extract hash from filename: $filename");
        return '';
    }
    
    # Query database
    my $sth = $storage_dbh->prepare("SELECT content FROM items WHERE hash = ?");
    $sth->execute($hash);
    my $row = $sth->fetchrow_arrayref();
    
    if ($row) {
        WriteLog("GetFile: Retrieved content for hash $hash");
        return decode_utf8($row->[0]);
    } else {
        WriteLog("GetFile: No content found for hash $hash");
        return '';
    }
}

sub PutFile { # $filename, $content ; stores content in SQLite
    my $filename = shift;
    my $content = shift;
    
    chomp $filename;
    
    state $initialized;
    if (!$initialized) {
        InitializeStorageDb();
        $initialized = 1;
    }
    
    # Extract or generate hash
    my $hash = ExtractHashFromFilename($filename);
    if (!$hash) {
        $hash = sha1_hex(encode_utf8($content));
        WriteLog("PutFile: Generated hash $hash for filename $filename");
    }
    
    # Store in database with history
    $storage_dbh->begin_work;
    
    eval {
        # Check if exists for version management
        my $sth = $storage_dbh->prepare("SELECT version FROM items WHERE hash = ?");
        $sth->execute($hash);
        my $existing = $sth->fetchrow_arrayref();
        
        my $version = $existing ? $existing->[0] + 1 : 1;
        my $operation = $existing ? 'update' : 'create';
        
        # Insert or update main record
        $storage_dbh->do(
            "INSERT OR REPLACE INTO items (hash, content, file_size, updated_at, version, checksum) VALUES (?, ?, ?, datetime('now'), ?, ?)",
            undef, $hash, encode_utf8($content), length($content), $version, $hash
        );
        
        # Add history record
        $storage_dbh->do(
            "INSERT INTO item_history (hash, content, version, operation) VALUES (?, ?, ?, ?)",
            undef, $hash, encode_utf8($content), $version, $operation
        );
        
        $storage_dbh->commit;
        WriteLog("PutFile: Stored content for hash $hash (version $version)");
        return 1;
    };
    
    if ($@) {
        $storage_dbh->rollback;
        WriteLog("PutFile: Error storing content: $@");
        return 0;
    }
}

sub ExtractHashFromFilename { # $filename ; extracts hash from various filename formats
    my $filename = shift;
    
    # Handle various filename patterns
    if ($filename =~ m/([a-f0-9]{40})\.txt$/) {
        return $1;  # Full hash filename
    } elsif ($filename =~ m/([a-f0-9]{7,40})/) {
        return $1;  # Partial hash
    } elsif ($filename =~ m/(\d{7,})\.txt$/) {
        # Numeric filename - convert to hash lookup
        return ConvertNumericToHash($1);
    }
    
    return '';
}

sub GetFileSize { # $filename ; returns file size from database
    my $filename = shift;
    chomp $filename;
    
    my $hash = ExtractHashFromFilename($filename);
    return 0 unless $hash;
    
    my $sth = $storage_dbh->prepare("SELECT file_size FROM items WHERE hash = ?");
    $sth->execute($hash);
    my $row = $sth->fetchrow_arrayref();
    
    return $row ? $row->[0] : 0;
}

sub FileExists { # $filename ; checks if file exists in database
    my $filename = shift;
    chomp $filename;
    
    my $hash = ExtractHashFromFilename($filename);
    return 0 unless $hash;
    
    my $sth = $storage_dbh->prepare("SELECT 1 FROM items WHERE hash = ? LIMIT 1");
    $sth->execute($hash);
    return $sth->fetchrow_array() ? 1 : 0;
}

sub DeleteFile { # $filename ; removes file from database
    my $filename = shift;
    chomp $filename;
    
    my $hash = ExtractHashFromFilename($filename);
    return 0 unless $hash;
    
    $storage_dbh->begin_work;
    
    eval {
        # Add deletion history record
        my $sth = $storage_dbh->prepare("SELECT version FROM items WHERE hash = ?");
        $sth->execute($hash);
        my $version = $sth->fetchrow_arrayref();
        $version = $version ? $version->[0] + 1 : 1;
        
        $storage_dbh->do(
            "INSERT INTO item_history (hash, content, version, operation) VALUES (?, '', ?, 'delete')",
            undef, $hash, $version
        );
        
        # Delete main record
        $storage_dbh->do("DELETE FROM items WHERE hash = ?", undef, $hash);
        
        $storage_dbh->commit;
        WriteLog("DeleteFile: Deleted content for hash $hash");
        return 1;
    };
    
    if ($@) {
        $storage_dbh->rollback;
        WriteLog("DeleteFile: Error deleting content: $@");
        return 0;
    }
}

1;
```

#### 3.2 Database Integration (`database.pl`)

Override key functions to work with the new storage:

```perl
sub DBGetItemFilePath { # $hash ; returns virtual file path
    my $hash = shift;
    
    # Return virtual path that file.pl can handle
    return "html/txt/$hash.txt";
}

sub DBAddItem { # enhanced to work with SQLite storage
    my ($path, $name, $author, $hash, $type, $error) = @_;
    
    # Verify content exists in storage before adding to index
    if (!FileExists("$hash.txt")) {
        WriteLog("DBAddItem: Content not found in storage for hash $hash");
        return 0;
    }
    
    # Proceed with normal DBAddItem logic
    # ... existing implementation
}
```

### 4. Migration Strategy

#### 4.1 Migration Script (`migrate_to_sqlite_storage.pl`)

```perl
#!/usr/bin/perl -T

use strict;
use 5.010;
use warnings;

sub MigrateFilesToSqliteStorage {
    my $htmlTxtDir = GetDir('html') . '/txt';
    my $migratedCount = 0;
    my $errorCount = 0;
    
    WriteLog("Starting migration from $htmlTxtDir to SQLite storage");
    
    # Initialize storage database
    InitializeStorageDb();
    
    # Find all .txt files
    my @files = glob("$htmlTxtDir/*.txt");
    push @files, glob("$htmlTxtDir/*/*.txt");  # Subdirectories
    
    foreach my $file (@files) {
        eval {
            my $content = GetFile($file);  # Use old GetFile initially
            if ($content) {
                # Use new PutFile to store in SQLite
                if (PutFile($file, $content)) {
                    # Mark as migrated
                    $storage_dbh->do(
                        "INSERT INTO migration_status (file_path, original_size) VALUES (?, ?)",
                        undef, $file, -s $file
                    );
                    $migratedCount++;
                    WriteLog("Migrated: $file");
                } else {
                    $errorCount++;
                    WriteLog("Failed to migrate: $file");
                }
            }
        };
        
        if ($@) {
            $errorCount++;
            WriteLog("Error migrating $file: $@");
        }
    }
    
    WriteLog("Migration complete: $migratedCount migrated, $errorCount errors");
    return $migratedCount;
}
```

### 5. Configuration and Activation

#### 5.1 Theme Configuration

Add to `default/setting/theme.list`:
```
sqlite-storage
```

#### 5.2 Theme Settings

Create theme-specific settings:
```
/default/theme/sqlite-storage/setting/
├── storage_db_path           # Custom database path
├── enable_compression        # Enable content compression
├── backup_interval          # Automatic backup interval
├── migration_batch_size     # Migration batch size
└── enable_history          # Keep content history
```

### 6. Compatibility and Integration

#### 6.1 Backward Compatibility

- All existing API functions (`GetFile`, `PutFile`, etc.) maintain same signatures
- Virtual file paths returned for compatibility with existing code
- Gradual migration support - can run alongside file-based storage

#### 6.2 Performance Optimizations

```sql
-- Additional indexes for common queries
CREATE INDEX idx_items_hash_prefix ON items(substr(hash, 1, 8));
CREATE INDEX idx_items_content_size ON items(length(content));

-- Full-text search capability
CREATE VIRTUAL TABLE items_fts USING fts5(hash, content);
```

#### 6.3 Backup and Recovery

```perl
sub BackupStorageDatabase {
    my $backupDir = GetDir('backup');
    my $timestamp = time();
    my $backupFile = "$backupDir/content_$timestamp.sqlite3";
    
    # SQLite backup API
    $storage_dbh->sqlite_backup_to_file($backupFile);
    WriteLog("Storage database backed up to $backupFile");
}
```

### 7. Testing Strategy

#### 7.1 Unit Tests
- Test all file operations (`GetFile`, `PutFile`, `DeleteFile`)
- Test migration functionality
- Test performance with large content

#### 7.2 Integration Tests
- Full site functionality with sqlite-storage theme
- Migration from file-based to SQLite storage
- Backup and recovery procedures

#### 7.3 Performance Benchmarks
- Compare file I/O vs SQLite operations
- Measure database size vs file system usage
- Test with various content sizes

### 8. Benefits of This Approach

1. **Single Database**: All content in one manageable file
2. **ACID Compliance**: Proper transaction support
3. **Better Backup**: Single file backup instead of thousands of files
4. **History Tracking**: Built-in versioning and change history
5. **Compression**: Future support for content compression
6. **Full-Text Search**: Native SQLite FTS support
7. **Atomic Operations**: No partial writes or corruption
8. **Portable**: Single file easy to move/deploy

### 9. Implementation Timeline

1. **Phase 1**: Create theme structure and basic file operations
2. **Phase 2**: Implement database schema and core functions
3. **Phase 3**: Build migration tools and scripts
4. **Phase 4**: Add performance optimizations and indexing
5. **Phase 5**: Implement backup/recovery and monitoring
6. **Phase 6**: Testing and documentation

### 10. Future Enhancements

- **Compression**: Automatic content compression for large items
- **Encryption**: Optional content encryption at rest
- **Replication**: Master-slave database replication
- **Cloud Storage**: Extension to cloud databases (PostgreSQL, MySQL)
- **Partitioning**: Date-based or size-based content partitioning

This implementation provides a clean, maintainable alternative storage method that leverages SQLite's reliability while maintaining full compatibility with the existing Pollyanna architecture.