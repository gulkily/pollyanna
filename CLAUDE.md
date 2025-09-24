# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Build: `./hike.sh build` or `./build.sh`
- Clean: `./hike.sh clean [all|html]` 
- Start server: `./hike.sh start` or `./hike.sh startpython`
- Run tests: `./hike.sh test` (basic test) or `python3 test/test.py` (Selenium smoke test)
- Database: `./hike.sh db` (sqlite3 CLI) or `./hike.sh guidb` (SQLite browser)
- Index data: `./hike.sh index [file]` (specific file) or `./hike.sh index` (all data)
- Template management: `./hike.sh refresh` (update templates from default)

## Code Style Guidelines
- Use Perl taint mode (`perl -T`) for all scripts
- Use strict, warnings, and specify minimum Perl version (use 5.010)
- Restrict PATH environment variable for security (`$ENV{PATH} = "/bin:/usr/bin"`)
- Use named subroutines with comments (e.g., `sub BuildMessage { ... } # BuildMessage()`)
- Sanitize paths and directories with regex pattern matching before use
- Include verbose error messages and sanity checks for critical operations
- Use die() for fatal errors and WriteLog() for non-fatal information

## Directory Structure
- `/default/` contains original template files that should never be edited directly
- `/config/` contains customized versions of the default templates
- When a file is missing in `/config/`, the system automatically copies it from `/default/`
- Use `require_once()` and `ensure_module()` to manage dependencies
- Templates are organized by type (perl, js, html, etc.) under `/template/` directories
- Themes are implemented as subdirectories under `/default/theme/`

## Database
- SQLite is the primary database (in cache/b/index.sqlite3)
- Default to append-only pattern for data storage
- Always sanitize SQL inputs and use proper error handling
- Maintain backward compatibility with older browsers