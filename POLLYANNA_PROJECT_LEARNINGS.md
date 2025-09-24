# Pollyanna Project Learnings

This document captures key learnings about the Pollyanna codebase discovered during implementation of the automatic archiving system.

## Project Structure & File Organization

### Directory Hierarchy
- `/default/` - Original template files that should **never be edited directly**
- `/config/` - Customized versions of default templates (this is where edits go)
- When a file is missing in `/config/`, the system automatically copies it from `/default/`
- Scripts live in `/default/template/perl/script/` or `/config/template/perl/script/`
- Configuration files go in `/config/setting/admin/` not `/default/setting/admin/`

### Template System
- Uses `require_once()` and `ensure_module()` to manage dependencies
- Templates are organized by type (perl, js, html, etc.) under `/template/` directories
- Themes are implemented as subdirectories under `/default/theme/`
- The system uses `GetTemplate()` function to load templates with theme override support

## Code Style & Conventions

### Perl Standards
- **Always use Perl taint mode** (`perl -T`) for all scripts
- Required headers: `use strict; use warnings; use 5.010; use utf8;`
- **Always restrict PATH** for security: `$ENV{PATH} = "/bin:/usr/bin"`
- Use named subroutines with comments (e.g., `sub BuildMessage { ... } # BuildMessage()`)

### Dependency Management
```perl
# Standard pattern for script dependencies:
require './utils.pl';           # Load utils.pl first
require_once('database.pl');    # Then use require_once for others
require_once('specific_module.pl');
```

### Security Patterns
- **Path Sanitization**: Use `IsSaneFilename($path)` for untainting file paths
  - This both validates AND untaints paths in one call
  - Returns the clean path on success, `0` on failure
- **Manual taint patterns**: `if ($var =~ m/^([^\s]+)$/) { $var = $1; } #security #taint`
- Always sanitize paths and directories with regex pattern matching before use

### Logging Conventions
```perl
# Standard WriteLog pattern:
WriteLog('FunctionName: descriptive message; $var = ' . $var . '; caller = ' . join(',', caller));

# For warnings:
WriteLog('FunctionName: warning: error description; caller = ' . join(',', caller));

# For successful operations:
WriteLog('FunctionName: operation completed; caller = ' . join(',', caller));
```

### Return Value Patterns
- `return 0;` - For failed validations/boolean false conditions
- `return '';` - For failed operations that should return strings  
- `return;` - For void functions that fail (no return value)
- `return $value;` - For successful operations returning data

### Error Handling
- Use `die()` for fatal errors 
- Use `WriteLog()` for non-fatal information and warnings
- Include verbose error messages and sanity checks for critical operations

## Database Architecture

### SQLite Backend
- Primary database: `cache/b/index.sqlite3`
- **Default to append-only pattern** for data storage
- Always sanitize SQL inputs and use proper error handling
- Maintain backward compatibility with older browsers

### Key Tables & Functions
- `item_flat` - Main item table with metadata
- `item_label` - Labels/tags for items  
- `item_parent` - Thread/reply relationships
- `item_attribute` - Additional item attributes

### Important Database Functions
- `DBGetAllItemsInThread($itemHash)` - Recursively gets all items in a thread
- `DBDeleteItemReferences(@hashes)` - Safely removes items from all related tables
- `SqliteQueryHashRef($query, @params)` - Returns array of hashrefs for results
- `SqliteGetValue($query, @params)` - Returns single scalar value

## Thread & Conversation System

### Thread Architecture
- Items can have parent-child relationships stored in `item_parent` table
- `DBGetAllItemsInThread()` recursively follows these relationships
- Threads should be treated atomically - don't break conversations by partial archival

### Pin System
- Items can be "pinned" using `#pin` label in `item_label` table
- Pinned items should be preserved regardless of age
- Pin detection: `SELECT COUNT(*) FROM item_label WHERE file_hash = ? AND label = 'pin'`

## File System Patterns

### Text File Storage
- Text files stored in `html/txt/` with hash-based subdirectory structure
- Path pattern: `txt/{first2chars}/{next2chars}/{fullhash}.txt`
- Use `GetPathFromHash()` to construct paths from hashes

### Archive System
- Manual archives use timestamp-based naming (epoch seconds)
- Automatic archives use date-based naming (`YYYY-MM-DD.tar.gz`)
- Archive directory structure:
  ```
  archive/
  ├── auto/
  │   ├── YYYY-MM-DD/
  │   │   ├── txt/
  │   │   └── archive_log.txt
  │   └── YYYY-MM-DD.tar.gz
  ```

## Configuration System

### Configuration Files
- Settings stored as simple text files in `/config/setting/admin/`
- Use `GetConfig('setting/path/name')` to read configuration values
- Boolean settings: `1` for true, `0` for false
- Numeric settings: plain integer values

### Theme System
- Multiple themes can be active simultaneously via `GetActiveThemes()`
- Theme-specific overrides in `/default/theme/{theme_name}/template/`
- Template resolution: theme templates override base templates

## Utility Functions (from utils.pl)

### Core Functions
- `require_once($module)` - PHP-style include-once functionality
- `ensure_module($module)` - Ensures module exists in config/ directory
- `WriteLog($message)` - Standardized logging function
- `GetTemplate($name)` - Template loading with theme support
- `GetConfig($path)` - Configuration value retrieval

### File Operations
- `IsSaneFilename($path)` - Path validation and untainting
- `GetFile($path)` - Read file contents
- `PutFile($path, $content)` - Write file contents  
- `AppendFile($path, $content)` - Append to file
- `PutHtmlFile($path, $content)` - Write HTML with special processing

### Validation Functions
- `IsItem($hash)` - Validates and untaints item hashes
- `IsFingerprint($key)` - Validates cryptographic fingerprints
- `IsSaneFilename($path)` - Validates and untaints file paths

## Build & Development System

### Build Commands (via hike.sh)
- `./hike.sh build` or `./build.sh` - Build project
- `./hike.sh clean [all|html]` - Clean build artifacts
- `./hike.sh start` or `./hike.sh startpython` - Start server
- `./hike.sh test` - Basic test, `python3 test/test.py` - Selenium tests

### Development Tools
- `./hike.sh db` - SQLite CLI access
- `./hike.sh guidb` - SQLite browser GUI
- `./hike.sh index [file]` - Index data files
- `./hike.sh refresh` - Update templates from default

## Security Considerations

### Taint Mode Requirements
- All scripts must run with `-T` (taint mode)
- All external input must be validated and untainted
- System calls require untainted parameters
- Use established patterns like `IsSaneFilename()` for validation

### Input Validation
- Always validate file paths before system operations
- Use regex patterns to match expected input formats
- Log all validation failures with context
- Sanitize SQL inputs and use parameterized queries

### File System Security
- Restrict PATH environment variable
- Validate directory traversal attempts
- Use absolute paths where possible
- Log all file operations for audit trails

## Performance & Scalability

### Database Optimization
- Use indexed queries where possible
- Batch operations when processing multiple items
- Consider thread-level operations rather than individual items
- Maintain referential integrity during cleanup operations

### Archive Strategy
- Thread-aware archiving prevents conversation fragmentation
- Compress archives for storage efficiency
- Use staging directories for atomic operations
- Clean up temporary files after successful operations

## Integration Points

### Existing Systems
- GPG integration for signing/encryption
- Chain logging system for audit trails
- Access log processing for new content
- Template system for UI generation

### Extension Opportunities
- Archive scheduling via cron
- Archive restoration functionality
- Archive search and indexing
- Metrics and reporting dashboard

## Testing & Validation

### Script Testing Patterns
- Run syntax check: `perl -T -c script.pl`
- Test with disabled features first
- Verify configuration file handling
- Test edge cases (no items, validation failures)
- Monitor log output for proper debugging information

### Data Integrity
- Always backup before destructive operations  
- Verify archive contents before database cleanup
- Test restoration procedures
- Validate thread relationship preservation

This knowledge base should serve as a reference for future development work on the Pollyanna project.