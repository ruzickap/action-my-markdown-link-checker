FROM node:current-alpine

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-link-checker"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-link-checker"

LABEL "com.github.actions.name"="My Markdown Link Checker"
LABEL "com.github.actions.description"="Check markdown files for broken links"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

# Comment to use latest version
ENV MARKDOWNLINT_LINK_CHECK_VERSION="v3.10.1"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN set -eux && \
    apk --update --no-cache add bash fd && \
    if [ -n "${MARKDOWNLINT_LINK_CHECK_VERSION+x}" ] ; then \
      npm install --global --production "markdown-link-check@${MARKDOWNLINT_LINK_CHECK_VERSION}" ; \
    else \
      npm install --global --production markdown-link-check ; \
    fi

COPY entrypoint.sh /entrypoint.sh

WORKDIR /mnt
ENTRYPOINT [ "/entrypoint.sh" ]
