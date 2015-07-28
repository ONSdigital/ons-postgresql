#!/bin/bash
#--------------------------------------------------------------
#
# NAME:    take_edbsnap.sh
#
# PURPOSE: Takes a DRITA snapshot for a given PPAS database
#          and clears out any older than a week.
#
# NOTES:   
#
# ARGS:    1. Host where the PostgreSQL server is running.
#          2. Port that the PostgreSQL service is listening on.
#          3. Database to take the snap in.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      10/10/14     S Bennett       Created
#--------------------------------------------------------------


#--------------------------------------------------------------
#--------------------------------------------------------------
function TAKE_EDBSNAP
{
  # Assign the variables within the function
  uHOST=$1
  uPORT=$2
  uDBASE=$3

  # Take the snapshot
  psql $uDBASE -h $uHOST -p $uPORT -c "select * from edbsnap()"

  # Housekeep those over 1 week old.
  # Firstly get the min and max values of the snaps that are out of date
  MIN=`psql $uDBASE -h $uHOST -p $uPORT -Atc "select nvl(min(edb_id),0) from edb\\$snap where snap_tm < now() - '3 days'::interval"`
  MAX=`psql $uDBASE -h $uHOST -p $uPORT -Atc "select nvl(max(edb_id),0) from edb\\$snap where snap_tm < now() - '3 days'::interval"`


  # Evaluate min/max. If zero's are returned no are out of date
  if [ $MIN != 0 ]
  then
    # purge all snaps from min to max
    psql $uDBASE -h $uHOST -p $uPORT -c "select * from purgesnap($MIN,$MAX)"
  fi
}


#--------------------------------------------------------------
# Main routine
#--------------------------------------------------------------
. $HOME/.bash_profile

# Must be run as the 'postgres' operating sytem user
EXEC_USER=`whoami`
if [ $EXEC_USER != 'postgres' ]
then
  printf "\nERROR: Script must be run as the postgres user\n"
  exit 1
fi

# Check the number of arguments passed.
if [ $# -ne 3 ]
then
  printf "\nUSAGE: %s <host> <port> <database>\n" $0
  exit 2
fi

# Assign the arguments to more descriptive variable names
HOST=$1
PORT=$2
DBASE=$3

# Connect to the database and take the snap by calling the function
# with the correct arguments.
TAKE_EDBSNAP $HOST $PORT $DBASE
