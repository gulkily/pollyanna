# Repository Guidelines
Pollyanna is an accessibility-first forum framework; use this guide to stay aligned with project conventions.

## Project Structure & Module Organization
- Core backend logic lives in `default/template/perl/`; keep local overrides in `config/template/perl/`.
- Generated runtime assets stay in `html/` (txt, image, chain logs). Never edit those by hand—regenerate through the tooling.
- Documentation belongs in `doc/` (singular). If you see a `docs/` tree, move its contents into `doc/` and remove it.
- Store AI-generated plans under `doc/ai_plans/`; keep developer logs (e.g., `bug.txt`, `todo.txt`) in the root `doc/` tree unless a deeper reorg is explicitly requested.
- Configuration and state belong in `config/` and `cache/`.
- There's really no testing framework at this time.
- Indexing safeguards: `setting/admin/index/text_binary_guard` (default on) skips binary-looking `.txt` files; opt into `setting/admin/index/mime_type_detection` when you want mislabelled files auto-routed via the system `file(1)` utility.

## Build, Test, and Development Commands
- `./build.sh` or `hike build` bootstraps the environment, syncs template Perl scripts, and runs the typed build pipeline (`perl -T ...`).
- `source hike.sh` to load the `hike` helper; common flows are `hike build`, `hike index` (full reindex), and `hike clean html` for safe regeneration.
- Run `hike refresh` after updating things in default/
- Need a local server? `perl -T config/template/perl/server_local_python.pl` starts a lightweight instance; stop it before committing.

## Coding Style & Naming Conventions
- Perl modules already enforce strict mode; indent with tabs and follow the existing CamelCase subs (e.g., `BuildMessage`). Keep config keys and filenames snake_case.
- HTML and template work must follow `HTML_STYLE_GUIDE.md`; JavaScript belongs to the rules in `JAVASCRIPT_STYLE_GUIDE.md`. Mirror class/id names used in the themes.
- Shell utilities are POSIX sh or bash—prefer portable syntax and run `./fix.sh` if editors add CRLF endings.

## Commit & Pull Request Guidelines
- Follow the existing log style: short, imperative subjects (lowercase ok) with optional `; filename` suffixes to flag primary touchpoints.
- Each PR should summarize intent, link related docs/issues, and include before/after captures for UI-visible adjustments.

## Security & Configuration Tips
- Never hard-code secrets; rely on files in `config/setting/...` and document new knobs inside `doc/settings.md`.
- Use `hike debug` sparingly—it rewires `config/debug`—and remove debugging traces before merge.
- Public-key imports now capture the key's original creation epoch (stored as `gpg_creation_timestamp`) when `setting/admin/gpg/index_creation_time` is enabled (default); disable it only if you need the legacy "indexed-at" behaviour.
