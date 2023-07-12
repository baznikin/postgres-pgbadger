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

  # pre-gzip old enough .html to save storage and cpu cycles
  # newer compress /index.html or wi'll loose links to previous days
  # do not compress weekly files and files changed 8 days ago or later so weekly index can be built
  find $PGBADGER_DATA -name index.html -mtime +8 | grep -v "/www/index.html" | grep -v week | xargs -n1 gzip --force --verbose
  # do not compress weekly files changed 38 days ago or later so monthly index can be built (if we'll build it in future)
  find $PGBADGER_DATA -name index.html -mtime +38 | grep -v "/www/index.html" | grep week | xargs -n1 gzip --force --verbose

  return 0
}


if [[ "true" == "${CRON}" || "1" == "${CRON}" ]]; then
  echo "run $CRON_SCHEDULE"
  echo "$CRON_SCHEDULE /entrypoint.sh $@" > /etc/crontabs/root
  export CRON=0
  nginx &
  crond -f
else
  echo "run one time"
  run_pgbadger $@
fi
