# Repository Guidelines

## Project Structure & Module Organization
- Root directory holds Bash scripts; keep runnable entrypoints in `bin/` and shared helpers in `lib/`.
- Place example usage snippets or fixtures in `examples/` to keep the root tidy.
- Add automated tests under `tests/` using `.bats` files for Bats test cases; mirror the script layout (e.g., `tests/lib/vars.bats` for `lib/vars.sh`).

## Build, Test, and Development Commands
- `shellcheck bin/*.sh lib/*.sh`: lint scripts for common Bash issues; run before opening a PR.
- `shfmt -w bin lib`: format Bash with consistent indentation; drop `-w` when you only want to see diffs.
- `bats tests`: execute the Bats suite; use `bats --filter '<name>' tests` to run a single file.
- `bash bin/<script>.sh --help`: verify CLIs surface help text without side effects.

## Coding Style & Naming Conventions
- Bash scripts should start with `#!/usr/bin/env bash` plus `set -euo pipefail` and `IFS=$'\n\t'` where whitespace handling matters.
- Prefer 2-space indentation, lowercase kebab-case filenames in `bin/`, and snake_case for functions and local variables; reserve uppercase for exported environment variables and constants.
- Validate inputs explicitly; avoid `eval`; quote expansions defensively (`"${var}"`).
- Keep functions small and composable; place library code in `lib/*.sh` and source it from entrypoints.

## Testing Guidelines
- Use Bats for behavior verification; one logical scenario per test with clear `@test` names like `@test "prints usage when missing args"`.
- Add smoke tests for each new CLI flag and regression tests for fixed bugs.
- If a script touches the filesystem, run tests inside a temporary directory to avoid polluting the repo.

## Commit & Pull Request Guidelines
- Write imperative, present-tense commit subjects (50–72 chars); include a short body when context is not obvious.
- Reference related issues in the PR description (`Closes #123`) and describe user-facing changes plus any risk areas.
- Include before/after examples or console output for behavioral changes; attach screenshots if a script produces user-visible text or formatted output.

## Security & Configuration Tips
- Never commit secrets or tokens; load them at runtime via environment variables or `.env` files ignored by Git.
- For scripts that shell out, prefer explicit whitelists for arguments and fail fast on unexpected input.
