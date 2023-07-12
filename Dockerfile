FROM alpine

LABEL maintainer="Andrei I Baznikin <a.baznikin@gmail.com>"

ARG PGBADGER_VER=12.1

RUN \
  apk update && \
  apk upgrade && \
  apk add nginx && \
  apk add perl perl-text-csv_xs && \
  apk add --virtual .build curl make && \
  curl -sL https://github.com/darold/pgbadger/archive/v${PGBADGER_VER}.tar.gz | tar zx && \
  ( \
    cd pgbadger-${PGBADGER_VER} && \
    perl Makefile.PL && \
    make install \
  ) && \
  rm -r pgbadger-${PGBADGER_VER} && \
  apk del --purge .build

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PGHOME=/home/postgres/pgdata
ENV PGLOGS=${PGHOME}/pg_log
ENV PGBADGER_DATA=/www
ENV PGBADGER_EXTRA_OPTIONS=--start-monday
ENV CRON=0
ENV CRON_SCHEDULE="5 * * * *"
ENV LOG_FORMAT=csv
ENV LOG_EXT=${LOG_FORMAT}

EXPOSE 80

VOLUME ${PGBADGER_DATA}

ENTRYPOINT ["/entrypoint.sh"]

CMD ["pgbadger"]