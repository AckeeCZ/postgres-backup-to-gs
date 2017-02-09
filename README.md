# Backup container for PostgreSQL instances to Google Storage

This image provides a cron daemon that runs daily backups from postgres (clustered or single instance) to Google Storage.

Following ENV variables must be specified:
 - `POSTGRES_HOST` contains the remote host (hostname or IP) connection string for pg_dump command line client option -h
 - `POSTGRES_PORT` contains the remote port number for pg_dump option -P
  - `postgresserver.domain.com:5432` in case of a single instance
 - `POSTGRES_DB` database name 
 - `POSTGRES_USER` username used for connecting to the database
 - `POSTGRES_PASSWORD` password of user `POSTGRES_USER` who has access to all dbs
 - `GS_URL` contains address in GS where to store backups, without the `gs://` prefix
  - `bucket-name/directory`
 - `CRON_SCHEDULE` cron schedule string, default '0 2 * * *'

