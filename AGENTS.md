# AGENTS.md

Repo-specific notes for agents. General contribution standards (commit format,
branching, linting tools) live in `~/.config/opencode/AGENTS.md`; only the
non-obvious, this-repo facts are below.

## What this repo is

A **Docker-based GitHub Action** that checks Markdown files for broken links.
It is not a Node/Terraform project despite linter mentions — the only source
code is shell + Docker + YAML.

Core wiring:

- `action.yml` — Action definition (`using: docker`, `image: Dockerfile`).
  Declares all 7 `inputs` (`config_file`, `debug`, `exclude`, `fd_cmd_params`,
  `quiet`, `search_paths`, `verbose`).
- `Dockerfile` — builds `node:current-alpine`, installs `bash`, `fd`, and
  npm `markdown-link-check`. Runs as `USER nobody`, `WORKDIR /mnt`.
- `entrypoint.sh` — the real logic. Reads `INPUT_*` env vars, uses `fd` to find
  `*.md` files, then runs `markdown-link-check`. `EXCLUDE` is written to a temp
  file and passed via `fd --ignore-file`.

When changing inputs, keep **four places in sync**: `action.yml` inputs,
`entrypoint.sh` `INPUT_*` mapping, `README.md` parameter table, and `tests.yml`.

## Editing gotchas

- **`markdown-link-check` version is pinned** in `Dockerfile`
  (`MARKDOWNLINT_LINK_CHECK_VERSION`) with a `# renovate:` comment. Update the
  ENV value, not an unpinned tag; Renovate manages bumps.
- **`fd` defaults**: `FD_CMD_PARAMS` defaults to
  `. -0 --extension md --type f --hidden --no-ignore`. Setting `fd_cmd_params`
  makes the Action ignore `exclude` and `search_paths` entirely.
- **`keep-sorted` blocks**: several files (`.dockerignore`, `.gitignore`,
  `.mega-linter.yml`, `.github/workflows/stale.yml`) wrap lists in
  `# keep-sorted start` / `# keep-sorted end`. Entries inside MUST stay
  alphabetically sorted or MegaLinter fails.
- Shell scripts use `set -Eeuo pipefail` and an `ERR` trap; preserve that.

## CI quirks (easy to trip over)

- **MegaLinter only runs on non-`main` branches** (`mega-linter.yml`,
  `branches-ignore: main`) and is **skipped** on `chore/renovate/*` and
  `release-please--*` branches. Push to a feature branch to get lint feedback.
- **README bash blocks are executed in CI.** `readme-commands-check.yml` greps
  every ` ```bash ` block in `README.md` and runs it with `bash -euxo pipefail`.
  Do not add illustrative-but-unrunnable bash fences to README; use `yaml` for
  workflow examples (the existing examples are `yaml`, so they are safe).
- **`tests.yml`** builds the Action locally (`uses: ./`) against fixtures in
  `tests/`. Note: the workflow references `tests/test2/normal.md`,
  `tests/test1/`, and `tests/test3-multiple-files/`, but only
  `tests/test-bad-mdfile/`, `tests/test1/`, `tests/test2/` exist on disk
  (`test3-multiple-files` is missing) — keep fixtures and workflow paths
  aligned when editing.
- `CHANGELOG.md` is excluded from nearly every linter (rumdl, lychee, devskim,
  global filter) and is auto-generated — do not hand-edit it.

## Linting locally (matches CI / MegaLinter `documentation` flavor)

- Markdown: `rumdl` (config `.rumdl.toml`; code blocks exempt from line length).
- Links: `lychee` (config `lychee.toml`; accepts 200/429, excludes private IPs).
- Shell: `shellcheck --exclude=SC2317` and
  `shfmt --case-indent --indent 2 --space-redirects`.
- Workflows: validate with `actionlint`; actions are pinned to full SHAs.

## Releases

`release-please` (`release-type: simple`, runs on `main`) opens the release PR
and, on merge, force-pushes moving `vMAJOR` / `vMAJOR.MINOR` tags. Version lives
in git tags + `CHANGELOG.md`, not a source file. Users pin via `@v1`.
