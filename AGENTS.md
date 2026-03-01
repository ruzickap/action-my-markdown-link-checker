# AI Agent Guidelines

## Project Overview

Docker-based GitHub Action (`action-my-markdown-link-checker`) that checks
Markdown files for broken links. It wraps the
[markdown-link-check](https://github.com/tcort/markdown-link-check) npm
package and uses [fd](https://github.com/sharkdp/fd) for file discovery.

Key files: `entrypoint.sh` (main logic), `Dockerfile` (image build),
`action.yml` (GitHub Action definition).

## Build and Test Commands

```bash
# Build the Docker image locally
docker build . --file Dockerfile

# Run the action locally against a directory
export INPUT_SEARCH_PATHS="tests/"
docker run --rm -t -e INPUT_SEARCH_PATHS \
  -v "${PWD}:/mnt" peru/my-markdown-link-checker

# Run with exclusions
export INPUT_EXCLUDE="test-bad-mdfile/bad.md CHANGELOG.md"
docker run --rm -t -e INPUT_EXCLUDE -e INPUT_SEARCH_PATHS \
  -v "${PWD}:/mnt" peru/my-markdown-link-checker

# Run with debug mode
export INPUT_DEBUG="true"
docker run --rm -t -e INPUT_DEBUG -e INPUT_SEARCH_PATHS \
  -v "${PWD}:/mnt" peru/my-markdown-link-checker
```

### Linting (via MegaLinter)

There is no single `lint` command. CI uses MegaLinter (`.mega-linter.yml`).
Run individual linters locally:

```bash
# Markdown linting
rumdl .

# Shell script linting and formatting
shellcheck --exclude=SC2317 entrypoint.sh
shfmt --case-indent --indent 2 --space-redirects -d entrypoint.sh

# Link checking
lychee --config lychee.toml .

# GitHub Actions validation
actionlint

# JSON validation (supports comments)
jsonlint --comments .github/renovate.json5

# Security scanning
checkov --quiet --skip-check CKV_GHA_7 -d .
trivy fs --severity HIGH,CRITICAL --ignore-unfixed .
```

### Tests

Tests run in CI via `.github/workflows/tests.yml`. There are four test
scenarios that exercise the action with different input combinations
(`search_paths`, `exclude`, `quiet`, `verbose`, `debug`, `.mlc_config.json`).
Test fixtures live in `tests/` subdirectories. There is no unit test
framework; testing is integration-based using the action itself.

## Shell Script Style (`entrypoint.sh`)

- **Shebang**: `#!/usr/bin/env bash`
- **Strict mode**: `set -Eeuo pipefail`
- **Formatter**: `shfmt --case-indent --indent 2 --space-redirects`
- **Linter**: `shellcheck` (exclude SC2317)
- **Indentation**: 2 spaces, no tabs
- **Variables**: UPPERCASE with braces: `${MY_VARIABLE}`
- **Defaults**: Use `${VAR:-}` for optional env vars
- **Arrays**: Use `declare -a` for arrays, `mapfile` for population
- **Functions**: Use `snake_case` (e.g., `print_error`, `error_trap`)
- **Output**: Use helper functions (`print_error`, `print_info`) with
  ANSI color codes for user-facing messages
- **Error handling**: Set `trap error_trap ERR` for error reporting
- **Comments**: Use `#` with a space; section headers use `####` blocks
- **Quoting**: Always quote variable expansions in arguments;
  use `# shellcheck disable=SCXXXX` when word splitting is intentional

## Markdown Style

- **Linter**: `rumdl` (Rust-based, configured in `.rumdl.toml`)
- **Line length**: Wrap at 72 characters (code blocks excluded)
- **Headings**: Proper hierarchy, no skipped levels
- **Code fences**: Always include language identifiers (`bash`, `json`)
- **Excluded from linting**: `CHANGELOG.md` (auto-generated)

## Dockerfile Style

- **Base image**: Pin with SHA digest (`@sha256:...`)
- **Shell**: `SHELL ["/bin/ash", "-eo", "pipefail", "-c"]`
- **Security**: Run as `USER nobody`, set `HEALTHCHECK NONE`
- **Dependencies**: Version-pin with Renovate comments
  (`# renovate: datasource=npm depName=...`)
- **kics exceptions**: Use `# kics-scan ignore-block` when needed

## GitHub Actions Workflow Style

- **Permissions**: Always set `permissions: read-all` at workflow level
- **Action pinning**: Pin to full SHA, add version comment
  (e.g., `@sha256abc # v6.0.2`)
- **Triggers**: Use path filters to limit unnecessary runs
- **Security exceptions**: Use `# kics-scan ignore-line` for self-refs
- **Timeout**: Set `timeout-minutes` on long-running jobs
- **Validate**: Run `actionlint` after any workflow/action change

## Link Checking (`lychee.toml`)

- Accepts HTTP 200 and 429 (rate limited)
- Caches results; re-checks 403/429 responses
- Excludes template variables (`%7B.*%7D`), shell variables (`\$`)
- Excludes `CHANGELOG.md` and `package-lock.json`
- Excludes all private IP addresses

## Security Scanning

- **Checkov**: Skips `CKV_GHA_7` (workflow_dispatch inputs)
- **DevSkim**: Ignores DS162092 (debug code), DS137138 (insecure URL);
  excludes `CHANGELOG.md`
- **KICS**: Fails only on HIGH severity
- **Trivy**: HIGH/CRITICAL only, ignores unfixed vulnerabilities

## Version Control

### Commit Messages

- **Format**: `<type>: <description>` (conventional commits)
- **Types**: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`,
  `style`, `perf`, `ci`, `build`, `revert`
- **Subject**: Imperative mood, lowercase, no period, max 72 chars
- **Body**: Wrap at 72 chars, explain what and why, reference issues
  with `Fixes`, `Closes`, `Resolves`

### Branching

- Follow Conventional Branch format: `<type>/<description>`
- Types: `feature/`, `feat/`, `bugfix/`, `fix/`, `hotfix/`,
  `release/`, `chore/`
- Use lowercase, hyphens, no trailing/leading/consecutive hyphens

### Pull Requests

- Create as **draft** initially
- Title must follow conventional commit format
- Include clear description and link related issues

## JSON Files

- Must pass `jsonlint --comments` validation
- Comments are allowed (e.g., in `renovate.json5`)

## Quality Checklist

- [ ] Shell scripts pass `shellcheck` and `shfmt` checks
- [ ] Markdown passes `rumdl` and `lychee` checks
- [ ] Docker image builds successfully
- [ ] GitHub Actions workflows pass `actionlint`
- [ ] Security scans pass (checkov, trivy, kics, devskim)
- [ ] Commits follow conventional commit format
- [ ] Actions pinned to full SHA with version comments
- [ ] Two-space indentation, no tabs
