#!/bin/bash
set -eo pipefail

backup_tool="/google-cloud-sdk/bin/gsutil"
backup_options="-m rsync -r"

# verify variables
if [ -z "$GS_URL" -o -z "$POSTGRES_HOST" -o -z "$POSTGRES_PORT" -o -z "$POSTGRES_DB" ]; then
	echo >&2 'Backup information is not complete. You need to specify GS_URL, POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB. No backups, no fun.'
	exit 1
fi

# verify gs config - ls bucket
$backup_tool ls "gs://${GS_URL%%/*}" > /dev/null

# set cron schedule TODO: check if the string is valid (five or six values separated by white space)
[[ -z "$CRON_SCHEDULE" ]] && CRON_SCHEDULE='0 2 * * *' && \
   echo "CRON_SCHEDULE set to default ('$CRON_SCHEDULE')"

# format hostname:port:database:username:password 
# for more information see https://www.postgresql.org/docs/9.1/static/libpq-pgpass.html
echo "*:*:*:*:$POSTGRES_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass

DB_URI="postgresql://$POSTGRES_USER@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
# add a cron job
echo "$CRON_SCHEDULE root  mkdir -p /tmp/backup ; rm -rf /tmp/backup/* && pg_dumpall --dbname=$DB_URI --file=/tmp/backup/dump.sql --verbose >> /var/log/cron.log 2>&1 && gzip -c /tmp/backup/dump.sql > /tmp/backup/dump.gz && $backup_tool $backup_options /tmp/backup/ gs://$GS_URL/ >> /var/log/cron.log 2>&1 && rm -rf /tmp/backup/*" >> /etc/crontab
crontab /etc/crontab

exec "$@"
