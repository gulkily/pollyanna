# Automatic 7-Day Archiving System Implementation Plan

## Overview
Develop a system that automatically archives items older than 7 days by removing them from the index database and
storing their text files in compressed archives, while respecting pinning exceptions.

## Current State Analysis
- Existing `compost.sql` identifies items older than 7 days but keeps them in database
- Manual archive system (`_dev_archive.pl`) exists but archives entire site
- Pin system (`#pin` tag) provides retention priority but needs integration
- Database schema supports time-based queries via `add_timestamp` field

## Implementation Plan

### Phase 1: Core Archive Logic
1. **Create automatic archiving script** (`default/template/perl/script/auto_archive.pl`)
   - Query items older than 7 days excluding pinned items
   - Extract text file paths from database records
   - Copy text files to archive staging area
   - Remove database records for archived items
   - Create compressed archive with date-based naming

2. **Archive directory structure**
   ```
   archive/
   ├── auto/
   │   ├── YYYY-MM-DD/
   │   │   ├── txt/
   │   │   └── archive_log.txt
   │   └── YYYY-MM-DD.tar.gz
   ```

### Phase 2: Pin System Integration
3. **Enhance pin detection logic**
   - Query `item_label` table for `#pin` tags
   - Create `IsPinned($fileHash)` function in utils.pl
   - Modify archive query to exclude pinned items

4. **Pin expiration handling**
   - The pins automatically have expiration dates
   - This date is the date of the item which applies the pin

### Phase 3: Database Operations
5. **Safe removal procedures**
   - Create backup queries before deletion
   - Remove from related tables: `item_attribute`, `item_label`, `item_flat`
   - Handle thread references: use `DBGetAllItemsInThread()` to get all thread items, find newest by `add_timestamp`, archive thread only if newest item exceeds retention period

6. **Archive metadata tracking**
   - Create `archive_log` table to track what was archived when
   - Store archive file paths and item counts

7. **Configuration options**
   - `default/setting/admin/auto_archive_enabled` - master switch
   - `default/setting/admin/archive_days` - customizable retention period
   - `default/setting/admin/archive_respect_pins` - honor pin tags

8. **Monitoring & reporting**
   - Archive size tracking
   - Items archived per run statistics
   - Failure notifications

## Technical Specifications

### Archive Query (excluding pins)
**Note**: This query identifies candidates, but each must be filtered through thread-aware logic using `DBGetAllItemsInThread()` to ensure entire threads aren't broken.

```sql
SELECT 
    item_flat.file_hash,
    item_flat.item_title,
    item_flat.add_timestamp,
    item_flat.item_type
FROM item_flat
LEFT JOIN item_label pin_check ON (
    item_flat.file_hash = pin_check.file_hash 
    AND pin_check.label = 'pin'
)
WHERE 
    item_flat.add_timestamp <= strftime('%s', 'now', '-7 day')
    AND pin_check.file_hash IS NULL
ORDER BY item_flat.add_timestamp ASC
```

### File Operations
- Use system `tar` command
- Compress with gzip for space efficiency
- Maintain file permissions and timestamps
- Handle large archive sizes (split if necessary)

### Database Cleanup Order  
1. For each archival candidate:
   - Use `DBGetAllItemsInThread()` to get complete thread
   - Find newest item in thread by `max(add_timestamp)`  
   - Only archive if newest item exceeds retention period
2. Use `DBDeleteItemReferences()` for cleanup

## Configuration Files Needed
- `default/setting/admin/auto_archive_enabled` (default: 0)
- `default/setting/admin/archive_retention_days` (default: 7)
- `default/setting/admin/archive_respect_pins` (default: 1)
- `default/setting/admin/archive_log_level` (default: info)

## Success Criteria
- Items older than 7 days are automatically archived if setting is enabled
- Pinned items remain in database regardless of age
- Database size remains manageable over time
- Archive files are accessible and restorable
- System performance unaffected during archiving
- Zero data loss during normal operations