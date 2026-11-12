FROM node:current-alpine@sha256:6bd9ab43c0ec0190ca7b2d193906cb8b7edf6e7f4afa43ddeccd6452710bffb5

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
