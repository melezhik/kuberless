FROM alpine:latest

RUN apk add raku-sparrow6 curl git zef

ENV SP6_REPO=http://sparrowhub.io/repo

ENV SP6_FORMAT_COLOR=1

RUN s6 --index-update

RUN s6 --install template6

COPY entry.raku /app/entry.raku

COPY templates /app/templates/

RUN mkdir -p /app/run /app/pid /app/log /app/bin /app/conf

ENTRYPOINT  ["/usr/bin/raku", "/app/entry.raku" ]
