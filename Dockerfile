FROM alpine:latest

RUN apk add raku-sparrow6 curl

ENV SP6_REPO=http://sparrowhub.io/repo

ENV SP6_FORMAT_COLOR=1

RUN s6 --index-update

COPY entry.raku /app/entry.raku

RUN mkdir -p /app/run /app/pid /app/log /app/bin

ENTRYPOINT  ["/usr/bin/raku", "/app/entry.raku" ]
