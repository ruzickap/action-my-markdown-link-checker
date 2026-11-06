FROM node:current-alpine@sha256:8996bb5821d62a8fd9bb27c1cb07462f3fdce6e47d640c6a881ead0b064ce216

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL repository="https://github.com/ruzickap/action-my-markdown-link-checker"
LABEL homepage="https://github.com/ruzickap/action-my-markdown-link-checker"

LABEL "com.github.actions.name"="My Markdown Link Checker"
LABEL "com.github.actions.description"="Check markdown files for broken links"
LABEL "com.github.actions.icon"="list"
LABEL "com.github.actions.color"="blue"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

COPY package.json package-lock.json /opt/app/

ENV PATH="/opt/app/node_modules/.bin:${PATH}"

RUN set -eux && \
    apk --update --no-cache add bash fd && \
    npm ci --omit=dev --prefix /opt/app

COPY entrypoint.sh /entrypoint.sh

USER 65534

WORKDIR /mnt

HEALTHCHECK NONE

ENTRYPOINT [ "/entrypoint.sh" ]
