# GitHub Actions: My Markdown Link Checker ✔

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-My%20Markdown%20Link%20Checker-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/my-markdown-link-checker)
[![license](https://img.shields.io/github/license/ruzickap/action-my-markdown-link-checker.svg)](https://github.com/ruzickap/action-my-markdown-link-checker/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/ruzickap/action-my-markdown-link-checker.svg)](https://github.com/ruzickap/action-my-markdown-link-checker/releases/latest)
[![GitHub release date](https://img.shields.io/github/release-date/ruzickap/action-my-markdown-link-checker.svg)](https://github.com/ruzickap/action-my-markdown-link-checker/releases)
![GitHub Actions status](https://github.com/ruzickap/action-my-markdown-link-checker/workflows/docker-image/badge.svg)
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/peru/my-markdown-link-checker.svg)](https://hub.docker.com/r/peru/my-markdown-link-checker)

This is a GitHub Action to check Markdown files for broken links.
It's using the [markdown-link-check](https://github.com/tcort/markdown-link-check)
and [fd](https://github.com/sharkdp/fd).

See the basic GitHub Action example:

```yaml
name: markdown_link_check

on:
  push:

name: Check markdown files for broken links
jobs:
  markdown_link_check:
    name: Check markdown files
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Markdown links check
        uses: ruzickap/action-my-markdown-link-checker@v1
```

## Parameters

Variables used by `action-my-markdown-link-checker` GitHub Action:

| Variable        | Default                                             | Description                                                                                                                                                                        |
| --------------- | ----------------------------------------------------| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config_file`   | (not defined)                                       | [Config file](https://github.com/tcort/markdown-link-check#config-file-format) used by [markdown-link-check](https://github.com/tcort/markdown-link-check)                         |
| `debug`         | (not defined)                                       | Enable debug mode for the [entrypoint.sh](entrypoint.sh) script (`set -x`)                                                                                                         |
| `exclude`       | (not defined)                                       | Exclude files or directories - see the [--exclude parameter](https://github.com/sharkdp/fd#excluding-specific-files-or-directories) of [fd](https://github.com/sharkdp/fd) command |
| `fd_cmd_params` | `. -0 --extension md --type f --hidden --no-ignore` | Set your own parameters for [fd](https://github.com/sharkdp/fd) command. `exclude` and `search_paths` parameters are ignored if this is set.                                       |
| `quiet`         | (not defined)                                       | Display errors only                                                                                                                                                                |
| `search_paths`  | (not defined)                                       | By default all `*.md` are checked in whole repository, but you can specify your directories                                                                                        |
| `verbose`       | (not defined)                                       | Displays detailed error information                                                                                                                                                |

Non of the parameters above are "mandatory".

## Full example

GitHub Action example:

```yaml
name: markdown_link_check

on:
  push:
    branches:
      - master

jobs:
  markdown_link_check:
  name: Check markdown files for broken links
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

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

## Running locally

It's possible to use the markdown link checks locally using docker:

```bash
docker run --rm -t -v "${PWD}/tests/test2:/mnt" peru/my-markdown-link-checker
```

Output:

```text
*** Start checking...
*** Running: fd . -0 --extension md --type f --hidden --no-ignore
*** Running: markdown-link-check  normal.md

FILE: normal.md
[✓] https://google.com

1 links checked.


*** Checks completed...
```

Or you can also use parameters:

```bash
export INPUT_EXCLUDE="CHANGELOG.md test1/excluded_file.md bad.md excluded_dir/"
export INPUT_SEARCH_PATHS="tests/"
export INPUT_VERBOSE="true"
docker run --rm -t -e INPUT_EXCLUDE -e INPUT_SEARCH_PATHS -e INPUT_VERBOSE -v "${PWD}:/mnt" peru/my-markdown-link-checker
```

Output:

```text
*** Start checking...
*** Running: fd . -0 --extension md --type f --hidden --no-ignore --exclude CHANGELOG.md --exclude test1/excluded_file.md --exclude bad.md --exclude excluded_dir/ tests/
*** Running: markdown-link-check --verbose tests/test2/normal.md

FILE: tests/test2/normal.md
[✓] https://google.com → Status: 200

1 links checked.


*** Checks completed...
```

The example with broken links may look like:

```shell
docker run --rm -t -e INPUT_SEARCH_PATHS -e INPUT_VERBOSE -v "${PWD}:/mnt" peru/my-markdown-link-checker
```

Output:

```text
*** Start checking...
*** Running: fd . -0 --extension md --type f --hidden --no-ignore tests/
*** Running: markdown-link-check --verbose tests/excluded_dir/excluded.md

FILE: tests/excluded_dir/excluded.md
[✓] https://google.com → Status: 200

1 links checked.


*** Running: markdown-link-check --verbose tests/test-bad-mdfile/bad.md

FILE: tests/test-bad-mdfile/bad.md
[✖] https://non-existing-domain.com → Status: 0 Error: getaddrinfo ENOTFOUND non-existing-domain.com
    at GetAddrInfoReqWrap.onlookup [as oncomplete] (dns.js:66:26) {
  errno: -3008,
  code: 'ENOTFOUND',
  syscall: 'getaddrinfo',
  hostname: 'non-existing-domain.com'
}

1 links checked.

ERROR: 1 dead links found!
[✖] https://non-existing-domain.com → Status: 0
*** ERROR: Something went wrong - see the errors above...
```
