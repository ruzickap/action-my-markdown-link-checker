# GitHub Action: My Markdown Link Checker

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-My%20Markdown%20Link%20Checker-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/my-markdown-link-checker)
[![license](https://img.shields.io/github/license/ruzickap/action-my-markdown-link-checker.svg)](https://github.com/ruzickap/action-my-markdown-link-checker/blob/main/LICENSE)
[![release](https://img.shields.io/github/release/ruzickap/action-my-markdown-link-checker.svg)](https://github.com/ruzickap/action-my-markdown-link-checker/releases/latest)
[![GitHub release date](https://img.shields.io/github/release-date/ruzickap/action-my-markdown-link-checker.svg)](https://github.com/ruzickap/action-my-markdown-link-checker/releases)
![GitHub Actions status](https://github.com/ruzickap/action-my-markdown-link-checker/workflows/docker-image/badge.svg)
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/peru/my-markdown-link-checker.svg)](https://hub.docker.com/r/peru/my-markdown-link-checker)

This is a GitHub Action to check Markdown files for broken links.
This Action uses the [markdown-link-check](https://github.com/tcort/markdown-link-check)
library and [fd](https://github.com/sharkdp/fd) command-line utility.

Below is a basic example of how to use this GitHub Action:

```yaml
name: markdown-link-check

on:
  push:

jobs:
  markdown-link-check:
    name: Check markdown files
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Markdown links check
        uses: ruzickap/action-my-markdown-link-checker@v1
```

## Parameters

Variables used by `action-my-markdown-link-checker` GitHub Action:

| Variable        | Default                                             | Description                                                                                                                                                                |
|-----------------|-----------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config_file`   | `.mlc_config.json` (if exists)                      | [Config file](https://github.com/tcort/markdown-link-check#config-file-format) used by [markdown-link-check](https://github.com/tcort/markdown-link-check)                 |
| `debug`         | (not defined)                                       | Enable debug mode for the [entrypoint.sh](entrypoint.sh) script (`set -x`) and `--verbose` for [markdown-link-check](https://github.com/tcort/markdown-link-check)         |
| `exclude`       | (not defined)                                       | Exclude files or directories - see the [--exclude parameter](https://github.com/sharkdp/fd#excluding-specific-files-or-directories) of [fd](https://github.com/sharkdp/fd) |
| `fd_cmd_params` | `. -0 --extension md --type f --hidden --no-ignore` | Set your own parameters for [fd](https://github.com/sharkdp/fd) command. `exclude` and `search_paths` parameters are ignored if this is set.                               |
| `quiet`         | (not defined)                                       | Display errors only                                                                                                                                                        |
| `search_paths`  | (not defined)                                       | By default, all `*.md` files in the entire repository are checked. This parameter allows you to specify particular directories to search.                                  |
| `verbose`       | (not defined)                                       | Displays detailed error information                                                                                                                                        |

None of the parameters listed above are mandatory.

If you need to exclude/ignore domains, add custom headers, or prevent specific
URLs from being checked, use the `config_file` option for [markdown-link-check](https://github.com/tcort/markdown-link-check).
See the [config file format documentation](https://github.com/tcort/markdown-link-check#config-file-format)
for details.

If a `.mlc_config.json` file is present in the root of your repository, it will
be automatically used as the `config_file`.

## Full GitHub Action Workflow Example

Full GitHub Action Workflow Example:

```yaml
name: markdown-link-check

on:
  push:
    branches:
      - main

jobs:
  markdown-link-check:
  name: Check markdown files for broken links
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Markdown links check
        uses: ruzickap/action-my-markdown-link-checker@v1
        with:
          config_file: mlc_config.json
          debug: true
          exclude: |
            my_exclude_dir/md_files/
            my_exclude_dir_2/markdown_files/
            CHANGELOG.md
          search_paths: |
            check_dir_1/md_files/
            check_dir_2/markdown_files/

      - name: Markdown links check - check only 'docs' directory and exclude CHANGELOG.md
        uses: ruzickap/action-my-markdown-link-checker@v1
        with:
          search_paths: |
            docs/
          exclude: |
            CHANGELOG.md
          verbose: true

      - name: Markdown links check - simple example
        uses: ruzickap/action-my-markdown-link-checker@v1

      - name: Markdown links check using pre-built container
        uses: docker://peru/my-markdown-link-checker@v1
```

Example of Periodic Execution (Cron Job):

```yaml
name: periodic-markdown-link-check

on:
  schedule:
    - cron: '8 8 * * 2'

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Markdown links check
        uses: ruzickap/action-my-markdown-link-checker@v1
```

Demo:

[![My Markdown Link Checker](https://asciinema.org/a/348733.svg)](https://asciinema.org/a/348733)

## Similar projects

* [https://github.com/gaurav-nelson/github-action-markdown-link-check](https://github.com/gaurav-nelson/github-action-markdown-link-check)
  * Great project, but it lacked functionality to exclude or skip files when
    last checked (2020-07-20).
* [https://github.com/ocular-d/md-linkcheck-action](https://github.com/ocular-d/md-linkcheck-action)
  * Similar project, but it does not offer as many advanced features.
* [https://github.com/peter-evans/link-checker](https://github.com/peter-evans/link-checker)
