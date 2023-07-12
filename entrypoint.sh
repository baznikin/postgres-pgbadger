#!/bin/sh

# based on https://github.com/easylo/pgbadger/blob/master/entrypoint.sh
# (c) Andrei I Baznikin (a.baznikin@gmail.com) 2023

set -euo pipefail

if [ "$1" != "pgbadger" ]; then
  set -- pgbadger "$@"
fi

mkdir -p "$PGBADGER_DATA"

run_pgbadger () {

  if [ "$(ls -A $PGBADGER_DATA)" ]; then
    echo "PGBADGER_DATA $PGBADGER_DATA contains data, try to process latest file"
    ls -1tr ${PGLOGS}/*.${LOG_FORMAT} | tail -1 | xargs -n1 $@ --outdir "$PGBADGER_DATA" --format "$LOG_FORMAT" --incremental --start-monday
  else
    echo "PGBADGER_DATA $PGBADGER_DATA is empty, try to process all files"
    ls -1tr ${PGLOGS}/*.${LOG_FORMAT} | xargs -n1 $@ --outdir "$PGBADGER_DATA" --format "$LOG_FORMAT" --incremental --start-monday
  fi

  return 0
}

if [[ 1 == "${CRON}" ]]; then

  echo "run $CRON_PATTERN"
  echo "$CRON_PATTERN /entrypoint.sh $@" > /etc/crontabs/root
  export CRON=0
  crond -f

else
  echo "run one time"
  run_pgbadger $@
fi
