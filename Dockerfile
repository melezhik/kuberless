FROM alpine:latest

RUN apk add raku-sparrow6

ENV SP6_REPO=http://sparrowhub.io/repo

ENV SP6_FORMAT_COLOR=1

RUN s6 --index-update

RUN s6 --search

RUN s6 --plg-run nano-setup

COPY entry.bash /app/entry.bash

ENTRYPOINT  ["/bin/sh", "/app/entry.bash" ]
