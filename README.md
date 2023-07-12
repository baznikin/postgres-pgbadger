# postgres-pgbadger
Generate and serve pgbadger reports. Minded as side-car container for zalando/spilo, but can be used separately.

## Features
* use [pgBadger](https://github.com/darold/pgbadger) to generate Postgres log analysis report
* create reports on schedule with cron
* serve reports by web with nginx
* compress old report files to save disk space and CPU cycles

## Environment variables
|Variable|Default value|Desciption|
|-|-|-|
| PGHOME | /home/postgres/pgdata | Postgres database home |
| PGLOGS | ${PGHOME}/pg_log | Postgres logs location |
| PGBADGER_DATA | /www | pgBadger reports location | 
| PGBADGER_EXTRA_OPTIONS | --start-monday | You can pass any additional options to pgBadger here |
| CRON | false | Run reports on schedule. By default it iterate logs only once and exit |
| CRON_SCHEDULE | "5 * * * *" | Cron schedule to generate reports |
| LOG_FORMAT | csv | pgBarger log format. Possible values: syslog, syslog2, stderr, jsonlog, csv, pgbouncer, logplex, rds and redshift |
| LOG_EXT | ${LOG_FORMAT} | Log file extension. By default save value as LOG_FORMAT |
