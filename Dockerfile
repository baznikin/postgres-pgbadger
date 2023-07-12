FROM alpine

ARG PGBADGER_VER=12.1

RUN \
  apk update && \
  apk upgrade && \
  apk add perl && \
  apk add perl-text-csv_xs && \
  apk add --virtual .build curl make && \
  curl -sL https://github.com/darold/pgbadger/archive/v${PGBADGER_VER}.tar.gz | tar zx && \
  ( \
    cd pgbadger-${PGBADGER_VER} && \
    perl Makefile.PL && \
    make install \
  ) && \
  rm -r pgbadger-${PGBADGER_VER} && \
  apk del --purge .build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PGHOME=/home/postgres/pgdata
ENV PGLOGS=${PGHOME}/pg_log
ENV PGBADGER_DATA=/www
ENV CRON=0
ENV CRON_SCHEDULE="0 3 * * *"
ENV LOG_FORMAT=csv

VOLUME ${PGBADGER_DATA}

ENTRYPOINT ["/entrypoint.sh"]

CMD ["pgbadger"]