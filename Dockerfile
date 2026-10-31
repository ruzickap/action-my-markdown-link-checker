FROM node:current-alpine@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94

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
