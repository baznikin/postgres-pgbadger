#!/bin/sh

# based on https://github.com/easylo/pgbadger/blob/master/entrypoint.sh (c) Laurent RICHARD <easylo@gmail.com>
# (c) Andrei I Baznikin <a.baznikin@gmail.com> 2023

set -euo pipefail

if [ "$1" != "pgbadger" ]; then
  set -- pgbadger "$@"
fi

mkdir -p "$PGBADGER_DATA"

run_pgbadger () {

  CMD=$@ ; export CMD
  if [ "$(ls -A $PGBADGER_DATA)" ]; then
    echo "PGBADGER_DATA $PGBADGER_DATA contains data, try to process latest 2 files"
    # If previous run was before midnight, then some records contains in previous log, some - in current. So, we always process both
    ls -1tr ${PGLOGS}/*.${LOG_EXT} | tail -2 | xargs -n1 -I % sh -c '{ ls -l %; ${CMD} --outdir "$PGBADGER_DATA" --format "$LOG_FORMAT" --incremental ${PGBADGER_EXTRA_OPTIONS} %; }'
  else
    echo "PGBADGER_DATA $PGBADGER_DATA is empty, try to process all files"
    ls -1tr ${PGLOGS}/*.${LOG_EXT} | xargs -n1 -I % sh -c '{ ls -l %; ${CMD} --outdir "$PGBADGER_DATA" --format "$LOG_FORMAT" --incremental ${PGBADGER_EXTRA_OPTIONS} %; }'
  fi

  return 0
}

if [[ "true" == "${CRON}" || "1" == "${CRON}" ]]; then
  env | sort
  echo "run $CRON_SCHEDULE"
  echo "$CRON_SCHEDULE /entrypoint.sh $@" > /etc/crontabs/root
  export CRON=0
  nginx &
  crond -f

else
  echo "run one time"
  run_pgbadger $@
fi
