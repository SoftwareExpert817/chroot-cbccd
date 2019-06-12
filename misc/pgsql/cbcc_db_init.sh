LOG=/var/storage/pgsql/init/cbcc_db_init.log

/usr/bin/psql -f /var/storage/pgsql92/init/cbcc_db_init.sql >>$LOG 2>&1
