#!/bin/bash
#--------------------------------------------------------------
#
# NAME:    create_3tier_user.sh
#
# PURPOSE: Creates the users and schemas for an application
#          within the PostgreSQL service.
#
# NOTES:   Adapted from original scripts of A Turrington.
#          Conforms to OTS standards of supplying a list file
#          of user names allowing multiple users to be created.
#          Requires subsequent permissions granting script.
#
# ARGS:    1. Full path of list file.
#          2. Host where the PostgreSQL server is running.
#          3. Port that the PostgreSQL service is listening on.
#          4. Database to connect to for schema creation.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      03/07/13     S Bennett       Created
# 2.0	   29/01/15	S Bennett	Added JBPM schema
#--------------------------------------------------------------


#--------------------------------------------------------------
# This function creates a database user.
# It is called multiple times from the main routine.
# -------------------------------------------------------------
function SETUP_USER
{
  # Assign the variables within the function
  uUSER_TIER=$1
  uHOST=$2
  uPORT=$3
  uDBASE=$4

  # Create the Role
  psql $uDBASE -h $uHOST -p $uPORT -c "create user $uUSER_TIER with login password '$uUSER_TIER'"
}

#--------------------------------------------------------------
# This function creates a database schema.
# It is called multiple times from the main routine.
#--------------------------------------------------------------
function SETUP_SCHEMA
{
  # Assign the variables within the function
  sUSER_TIER=$1
  sHOST=$2
  sPORT=$3
  sDBASE=$4

  # Create the schema
  psql $sDBASE -h $sHOST -p $sPORT -c "create schema $sUSER_TIER authorization $sUSER_TIER"
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
# and create the appropriate users and schemas to match
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

  printf "PROGRESS:   Creating: %s\n" $USER_TIER
  SETUP_USER $USER_TIER $HOST $PORT $DBASE 

  printf "PROGRESS:   Creating: %s\n" $APPS_TIER
  SETUP_USER $APPS_TIER $HOST $PORT $DBASE
  SETUP_SCHEMA $APPS_TIER $HOST $PORT $DBASE

  if [ $NUM_TIER -eq 6 ]
  then

    printf "PROGRESS:   Creating: %s\n" $INT_TIER
    SETUP_USER $INT_TIER $HOST $PORT $DBASE
    SETUP_SCHEMA $INT_TIER $HOST $PORT $DBASE

    printf "PROGRESS:   Creating: %s\n" $EXT_TIER
    SETUP_USER $EXT_TIER $HOST $PORT $DBASE
    SETUP_SCHEMA $EXT_TIER $HOST $PORT $DBASE

    printf "PROGRESS:   Creating: %s\n" $SHR_TIER
    SETUP_USER $SHR_TIER $HOST $PORT $DBASE
    SETUP_SCHEMA $SHR_TIER $HOST $PORT $DBASE

    printf "PROGRESS:   Creating: %s\n" $JBPM_TIER
    SETUP_USER $JBPM_TIER $HOST $PORT $DBASE
    SETUP_SCHEMA $JBPM_TIER $HOST $PORT $DBASE
  
  else
   
    printf "PROGRESS:   Creating: %s\n" $DATA_TIER
    SETUP_USER $DATA_TIER $HOST $PORT $DBASE
    SETUP_SCHEMA $DATA_TIER $HOST $PORT $DBASE

  fi

done
