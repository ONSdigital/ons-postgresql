#!/bin/bash
#------------------------------------------------------------
#
# NAME: postgres_cluster_hot_backup.sh
#
# PURPOSE: hot backups for the EDC dev PostgreSQL databases
#          Will also do housekeeping of backups and archived
#          WAL files.
#
# NOTES: This calls pg_basebackup to do a daily, full, hot  
#        backup. The frequency can be reduced if load is high.
#        Housekeeping maintains n days online be retained.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      10/06/13     Steve Bennett   Created
#------------------------------------------------------------

# Will run from the crontab as the 'postgres' user.
# Check the number of arguments passed in.
if [ $# -ne 1 ]
then
  echo ""
  echo "ERROR: invalid number of arguments"
  echo "Usage: `basename $0` {port}"
  echo ""
  echo "    port:            The port number the cluster is listening on."
  echo ""
  exit 1
fi

# Get the port as arguments
BK_PORT=$1

# Get the current date
TODAY=`date +%d%m%Y`

# Configure the backup location. This incorporates the date
# and so is different each day.
BK_ROOT=/u01/app/postgres/backups/cluster_$BK_PORT
BK_DIR=/u01/app/postgres/backups/cluster_$BK_PORT/$TODAY
WAL_ROOT=/u01/app/postgres/walarchive/cluster_$BK_PORT
PG_BIN=/usr/pgsql-9.2/bin

# Take the backup using the pg_basebackup utility
# Configure as a compressed tar
$PG_BIN/pg_basebackup -p $BK_PORT -D $BK_DIR -F t -z -U backup_user -w

# Check the return status of pg_basebackup. It is not infallible
# but is a good indicator of success or otherwise
#if [ $? -ne 0 ]
#then
  #echo "Postgres Backup Failure"
#fi


# Now the backups are taken - remove those over 7 days old.
`find $BK_ROOT -name '*' -mtime +4 -type d -exec rm -rf '{}' \;`

# Finally remove the archived WAL files that are no longer required.
`find $WAL_ROOT -name '*' -mtime +4 -exec rm '{}' \;` 
