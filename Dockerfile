FROM node:current-alpine@sha256:40cd011b55415bc894e45b02fdd5a5dfde056921b7d23a64c74f80497af48797

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-link-checker"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-link-checker"

LABEL "com.github.actions.name"="My Markdown Link Checker"
LABEL "com.github.actions.description"="Check markdown files for broken links"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

# renovate: datasource=npm depName=markdown-link-check versioning=npm
ENV MARKDOWNLINT_LINK_CHECK_VERSION="3.15.0"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN set -eux && \
    apk --update --no-cache add bash fd && \
    npm install --global --production "markdown-link-check@v${MARKDOWNLINT_LINK_CHECK_VERSION}"

COPY entrypoint.sh /entrypoint.sh

USER 65534

WORKDIR /mnt

HEALTHCHECK NONE

ENTRYPOINT [ "/entrypoint.sh" ]
