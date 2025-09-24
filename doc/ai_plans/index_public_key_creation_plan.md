# Public Key Creation Timestamp Plan

## Goals
- Capture the original creation time embedded in a public key when it is indexed.
- Store that timestamp alongside the existing indexing timestamp so archival imports reflect their historical age.
- Keep behaviour optional/configurable to avoid surprising existing installations.

## Step 1 – Locate Key Indexing Flow
- Trace how public keys enter the system (likely via `index_text_file.pl` + `GpgParse` in `gpgpg.pl`).
- Confirm which helper currently writes key metadata to the database (e.g., `DBAddItemAttribute` with labels like `gpg_key`).
- Map where the current “index time” is persisted so we can add an additional attribute without breaking consumers.

## Step 2 – Extract Creation Time
- Use `gpg --with-colons --list-packets` or `gpg --with-colons --list-keys` to capture the `creation date (ctime)` field; prefer the parsing utility already used in `GpgParse` if available.
- Add a helper (`GetGpgKeyCreationTime`) that, given a key file or fingerprint, returns an epoch timestamp.
- Decide on error-handling: fall back to undef if the key lacks a creation time or the command fails; log a warning but do not abort indexing.

## Step 3 – Persist Timestamp
- Add a new item attribute named `gpg_creation_timestamp` so downstream tooling recognises it as a timestamp.
- Guard writes behind `setting/admin/gpg/index_creation_time` (default on) to allow quick rollback.
- Ensure the added attribute is flushed together with other `DBAdd…('flush')` calls so batching behaviour remains consistent.
- Update any timestamp whitelists (e.g., `DBGetAddedTime` in `database.pl`) so the main item dialog can treat `gpg_creation_timestamp` as a selectable “item time”.

## Step 4 – Surface & Test
- Update any UI components that display key metadata (profile pages, admin dialogs) to include the new creation timestamp when present, falling back to the indexing time otherwise.
- Extend automated tests or add a regression script that indexes a known key and asserts both timestamps differ for archival imports.
- Document the behaviour and new setting in `doc/settings.md`, add the display string under `default/string/en/item_attribute/`, and note the dual timestamps in contributor guidance (`AGENTS.md`).

## Step 5 – Migration & Rollout
- Provide an optional maintenance task to backfill existing keys: re-run the key parsing step and populate `gpg_creation_timestamp` for entries missing it.
- Communicate in release notes that user “registration time” now reflects historical key creation when available, reducing confusion during archival imports.
