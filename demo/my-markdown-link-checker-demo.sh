#!/usr/bin/env bash
# shellcheck disable=SC2016

# Record using: termtosvg --screen-geometry 93x30 --command ./my-markdown-link-checker-demo.sh

set -u

################################################
# include the magic
################################################
test -s ./demo-magic.sh || curl --silent https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh > demo-magic.sh
# shellcheck disable=SC1091
. ./demo-magic.sh

################################################
# Configure the options
################################################

#
# speed at which to simulate typing. bigger num = faster
#
export TYPE_SPEED=20

# Uncomment to run non-interactively
export PROMPT_TIMEOUT=1

# No wait
export NO_WAIT=false

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
#DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "
export DEMO_PROMPT="${GREEN}➜ ${CYAN}$ "

# hide the evidence
clear

p '* This is an example of my-markdown-link-checker usage...'

p ''
p '* Run the container image "peru/my-markdown-link-checker" to start checking "md" files in the "tests" directory:'
pe 'export INPUT_SEARCH_PATHS="tests/"'
pe 'docker run --rm -t -e INPUT_SEARCH_PATHS -v "${PWD}:/mnt" peru/my-markdown-link-checker'

sleep 3

p ''
p '* As you can see, there is a dead link (https://non-existing-domain.com) in the file tests/test-bad-mdfile/bad.md'

p ''
p "* You can create a config file for markdown-link-check and ignore this domain from checks:"
pe 'cat > .mlc_config.json << EOF
{
  "ignorePatterns": [
    {
      "pattern": "^https://non-existing-domain.com"
    }
  ]
}
EOF
'
pe 'docker run --rm -t -e INPUT_SEARCH_PATHS -v "${PWD}:/mnt" peru/my-markdown-link-checker'
pe 'rm .mlc_config.json'

sleep 3

p ''
p "* Or you can exclude this file from being checked:"
pe 'export INPUT_EXCLUDE="test-bad-mdfile/bad.md test1/CHANGELOG.md"'
pe 'docker run --rm -t -e INPUT_EXCLUDE -e INPUT_SEARCH_PATHS -v "${PWD}:/mnt" peru/my-markdown-link-checker'

sleep 3

p ''
p "* Use verbose mode if you want more details:"
pe 'export INPUT_VERBOSE="true"'
pe 'docker run --rm -t -e INPUT_EXCLUDE -e INPUT_VERBOSE -e INPUT_SEARCH_PATHS -v "${PWD}:/mnt" peru/my-markdown-link-checker'

sleep 3

p ''
p '* You can also specify the command-line parameters for the fd command if you need advanced search:'
pe 'export INPUT_FD_CMD_PARAMS=". -0 --extension md --type f --hidden --no-ignore --exclude test1/excluded_file.md --exclude bad.md --exclude CHANGELOG.md tests/"'
pe 'docker run --rm -t -e INPUT_FD_CMD_PARAMS -v "${PWD}:/mnt" peru/my-markdown-link-checker'

sleep 3

p ''
p '* If you are in trouble you can try the debug mode:'
pe 'export INPUT_SEARCH_PATHS="tests/"'
pe 'export INPUT_DEBUG="true"'
pe 'docker run --rm -t -e INPUT_DEBUG -e INPUT_SEARCH_PATHS -v "${PWD}:/mnt" peru/my-markdown-link-checker'

sleep 3

p ''
p '* If you run the docker command without additional environment parameters - it will check all "md" files in current directory. That is the simplest way:'
pe 'docker run --rm -t -v "${PWD}:/mnt" peru/my-markdown-link-checker'

sleep 3

p ''
p '* Enjoy ;-) ...'

sleep 3

rm ./demo-magic.sh
