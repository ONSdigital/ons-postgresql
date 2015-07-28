#!/bin/bash
#--------------------------------------------------------------
#
# NAME:    drop_3tier_user.sh
#
# PURPOSE: drops the users and schemas for an application
#          within the PostgreSQL service.
#
# NOTES:   This utility is primarily used for test/dev
#          environments where frequent rebuilds are the norm.
#          Takes a list file to allow multiple users and 
#          schemas to be processed at once
#
# ARGS:    1. Full path of list file.
#          2. Host where the PostgreSQL server is running.
#          3. Port that the PostgreSQL service is listening on.
#          4. Database to connect to for schema creation.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      03/07/13     S Bennett       Created
#--------------------------------------------------------------


#--------------------------------------------------------------
# This function removes a database schema.
# It is called multiple times from the main routine.
# -------------------------------------------------------------
function REMOVE_SCHEMA
{
  # Assign the variables within the function
  sUSER_TIER=$1
  sHOST=$2
  sPORT=$3
  sDBASE=$4

  # drop the Schema
  psql $sDBASE -h $sHOST -p $sPORT -c "drop schema $sUSER_TIER cascade"
}

#--------------------------------------------------------------
# This function removes a database user.
# It is called multiple times from the main routine.
#--------------------------------------------------------------
function REMOVE_USER
{
  # Assign the variables within the function
  uUSER_TIER=$1
  uHOST=$2
  uPORT=$3
  uDBASE=$4

  # drop the role
  psql $uDBASE -h $uHOST -p $uPORT -c "drop user $uUSER_TIER cascade"
}


#--------------------------------------------------------------
# Main routine
#--------------------------------------------------------------
# Must be run as the 'postgres' operating sytem user
EXEC_USER=`whoami`
if [ $EXEC_USER != 'postgres' ]
then
  printf "\nERROR: Script must be run as the postgres user\n"
  exit 1
fi

# Check the number of arguments passed.
if [ $# -ne 4 ]
then
  printf "\nUSAGE: %s <filename> <host> <port> <database>\n" $0
  exit 2
fi

# Assign the argument to a more descriptive variable name
LIST_FILE=$1
HOST=$2
PORT=$3
DBASE=$4

# Check that the file name passed in exists as a file
if [ ! -f $LIST_FILE ]
then
  printf "\nERROR: File %s does not exist\n" $LIST_FILE
  exit 3
fi

printf "\nPROGRESS: Using list file: %s\n" $LIST_FILE

# This loop will process each name (row) in the $LIST_FILE
# and drop the appropriate users and schemas to match
# the OTS 3 tier policy.
for ROW in `grep -v '^#' $LIST_FILE`
do

  USERNAME=`echo $ROW | cut -d: -f1`
  NUM_TIER=`echo $ROW | cut -d: -f2`  

  printf "\nPROGRESS: Processing name: %s\n" $USERNAME

  USER_TIER=${USERNAME}_user
  APPS_TIER=${USERNAME}_apps
  INT_TIER=${USERNAME}_int
  EXT_TIER=${USERNAME}_ext
  SHR_TIER=${USERNAME}_shr
  DATA_TIER=${USERNAME}_data
  JBPM_TIER=${USERNAME}_jbpm


  if [ $NUM_TIER -eq 6 ]
  then

    printf "PROGRESS:   Removing: %s\n" $INT_TIER
    REMOVE_SCHEMA $INT_TIER $HOST $PORT $DBASE

    printf "PROGRESS:   Removing: %s\n" $EXT_TIER
    REMOVE_SCHEMA $EXT_TIER $HOST $PORT $DBASE

    printf "PROGRESS:   Removing: %s\n" $SHR_TIER
    REMOVE_SCHEMA $SHR_TIER $HOST $PORT $DBASE
    REMOVE_USER $INT_TIER $HOST $PORT $DBASE
    REMOVE_USER $EXT_TIER $HOST $PORT $DBASE
    REMOVE_USER $SHR_TIER $HOST $PORT $DBASE
    REMOVE_USER $JBPM_TIER $HOST $PORT $DBASE

  else

    printf "PROGRESS:   Removing: %s\n" $DATA_TIER
    REMOVE_SCHEMA $DATA_TIER $HOST $PORT $DBASE
    REMOVE_USER $DATA_TIER $HOST $PORT $DBASE

  fi

  printf "PROGRESS:   Removing: %s\n" $APPS_TIER
  REMOVE_SCHEMA $APPS_TIER $HOST $PORT $DBASE
  REMOVE_USER $APPS_TIER $HOST $PORT $DBASE

  printf "PROGRESS:   Removing: %s\n" $USER_TIER
  REMOVE_USER $USER_TIER $HOST $PORT $DBASE

done
