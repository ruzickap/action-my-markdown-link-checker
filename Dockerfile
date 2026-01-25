FROM node:current-alpine@sha256:d1cdf008963e1627f47c4426c33481e538190300ad2514e9f8d5c75755888521

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
