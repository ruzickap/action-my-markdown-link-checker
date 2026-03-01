FROM node:current-alpine@sha256:18e02657e2a2cc3a87210ee421e9769ff28a1ac824865d64f74d6d2d59f74b6b

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-link-checker"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-link-checker"

LABEL "com.github.actions.name"="My Markdown Link Checker"
LABEL "com.github.actions.description"="Check markdown files for broken links"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

# renovate: datasource=npm depName=markdown-link-check versioning=npm
ENV MARKDOWNLINT_LINK_CHECK_VERSION="3.14.2"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# kics-scan ignore-block
RUN set -eux && \
    apk --update --no-cache add bash fd && \
    npm install --global --production "markdown-link-check@v${MARKDOWNLINT_LINK_CHECK_VERSION}"

COPY entrypoint.sh /entrypoint.sh

USER nobody

WORKDIR /mnt

HEALTHCHECK NONE

ENTRYPOINT [ "/entrypoint.sh" ]
