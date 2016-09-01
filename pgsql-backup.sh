#!/bin/sh

#
# Change this variables for your environment
# 

# Postgresql user for backup
PGUSER="postgres"
# Host with PostgreSQL Server
PGHOST="127.0.0.1"
# Directory in which backups are store ( if folder does no exist, it will be created)
DEST="/var/spool/pgsql/pg_dump"
# DO NOT BACKUP these databases, delemiter SPACE
IGN="template0 template1 postgres"
# Backup rotation 
ROTATION="7"

PSQL="$(which psql)"
PG_DUMP="$(which pg_dump)"
FIND="$(which find)"
MKDIR="$(which mkdir)"
WC="$(which wc)"
NOW="$(date +"%Y-%m-%d-%H:%M")"

DBS="$($PSQL -U $PGUSER -h $PGHOST -t -c "SELECT datname from pg_database;" postgres)"

for db in $DBS
do

SKIPDB=0

    if [ "$IGN" != "" ]; then
        for i in $IGN
		do
            if [ "$db" = "$i" ]; then
                SKIPDB=1
            fi
        done
    fi

    if [ "$SKIPDB" -eq 0 ]; then
        MBD="$DEST/$db"
        
        if [ ! -d $MBD ] ; then
            $MKDIR -p $MBD
        fi
        
        FILE="$MBD/$db.$NOW.dump"
        $PG_DUMP -U $PGUSER -h $PGHOST -Fc $db > $FILE
        FNUM="$($FIND $MBD/* | $WC -l)"
        
        if [ $FNUM -ge 0 ] ; then
            $FIND $MBD/* -type f -mtime +$ROTATION -delete
        fi  
    fi
done
