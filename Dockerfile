FROM alpine:latest

RUN apk add raku-sparrow6

ENV SP6_REPO=http://sparrowhub.io/repo

ENV SP6_FORMAT_COLOR=1

RUN s6 --index-update

COPY entry.bash /app/entry.raku

ENTRYPOINT  ["/bin/raku", "/app/entry.raku" ]
