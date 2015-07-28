#!/bin/bash
#--------------------------------------------------------------
#
# NAME:    set_3tier_privileges.sh
#
# PURPOSE: Sets the default privileges of the postgres database
#          users within the context of the 3 tier model.
#
# NOTES:   Takes a list file containing the application "name"
#          and assigns the priviliges at the user, apps and
#          data tier.
#
# ARGS:    1. Full path of list file.
#          2. Host where the PostgreSQL server is running.
#          3. Port that the PostgreSQL service is listening on.
#          4. Database to connect to for schema creation.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      05/07/13     S Bennett       Adapted for compliance
# 2.0	   29/01/15	S Bennett	Added jbpm schema
#--------------------------------------------------------------


#--------------------------------------------------------------
# This function assigns the privileges to the _user schema.
#--------------------------------------------------------------
function ASSIGN_USER_PRIVS
{
  # Assign the variables within the function
  uUSER_TIER=$1
  uPREFIX=$2
  uHOST=$3
  uPORT=$4
  uDBASE=$5
  uNUM_TIER=$6

  # Setup the search path
  if [ $uNUM_TIER -eq 6 ]
  then
    psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uUSER_TIER set search_path = ${uPREFIX}_INT, ${uPREFIX}_EXT, ${uPREFIX}_SHR, ${uPREFIX}_APPS;"
  else
    psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uUSER_TIER set search_path = ${uPREFIX}_DATA, ${uPREFIX}_APPS;"
  fi
  
  # Grant usage on the application and data schemas to the user role
  if [ $uNUM_TIER -eq 6 ]
  then

    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_INT to $uUSER_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_EXT to $uUSER_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_SHR to $uUSER_TIER;"

  else

    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_DATA to $uUSER_TIER;"

  fi

  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_APPS to $uUSER_TIER;"

  # Grant object privileges to the user role
  psql $uDBASE -h $uHOST -p $uPORT -c "grant execute on all functions in schema ${uPREFIX}_APPS to $uUSER_TIER;"

  if [ $uNUM_TIER -eq 6 ]
  then

    psql $uDBASE -h $uHOST -p $uPORT -c "grant select on all tables in schema ${uPREFIX}_INT to $uUSER_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant select on all tables in schema ${uPREFIX}_EXT to $uUSER_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant select on all tables in schema ${uPREFIX}_SHR to $uUSER_TIER;"

  else

    psql $uDBASE -h $uHOST -p $uPORT -c "grant select on all tables in schema ${uPREFIX}_DATA to $uUSER_TIER;"

  fi

}


#--------------------------------------------------------------
# This function assigns the privileges to the _apps schema.
#--------------------------------------------------------------
function ASSIGN_APPS_PRIVS
{
  # Assign the variables within the function
  uAPPS_TIER=$1
  uPREFIX=$2
  uHOST=$3
  uPORT=$4
  uDBASE=$5
  uNUM_TIER=$6

  # Setup the search path
  if [ $uNUM_TIER -eq 6 ]
  then

    psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uAPPS_TIER set search_path = ${uPREFIX}_APPS, ${uPREFIX}_EXT, ${uPREFIX}_SHR, ${uPREFIX}_INT;"

  else
 
    psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uAPPS_TIER set search_path = ${uPREFIX}_APPS, ${uPREFIX}_DATA;"

  fi
 
  # Grant usage on the data schemas to the application user
  if [ $uNUM_TIER -eq 6 ]
  then

    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_INT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_EXT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_SHR to $uAPPS_TIER;"

  else

    psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_DATA to $uAPPS_TIER;"

  fi

  # Grant all on application user's own schema
  psql $uDBASE -h $uHOST -p $uPORT -c "grant all on schema ${uPREFIX}_APPS to $uAPPS_TIER;"

  # Grant object permissions to the application role
  if [ $uNUM_TIER -eq 6 ]
  then

    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all tables in schema ${uPREFIX}_INT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all sequences in schema ${uPREFIX}_INT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all functions in schema ${uPREFIX}_INT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all tables in schema ${uPREFIX}_EXT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all sequences in schema ${uPREFIX}_EXT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all functions in schema ${uPREFIX}_EXT to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all tables in schema ${uPREFIX}_SHR to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all sequences in schema ${uPREFIX}_SHR to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all functions in schema ${uPREFIX}_SHR to $uAPPS_TIER;"

  else

    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all tables in schema ${uPREFIX}_DATA to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all sequences in schema ${uPREFIX}_DATA to $uAPPS_TIER;"
    psql $uDBASE -h $uHOST -p $uPORT -c "grant all on all functions in schema ${uPREFIX}_DATA to $uAPPS_TIER;"

  fi
}


#--------------------------------------------------------------
# These functions assigns the privileges to the data tier schemas
# This can be _data, _ext, _int or _shr dependent on the
# application.
#--------------------------------------------------------------
function ASSIGN_INT_DATA_PRIVS
{
  # Assign the variables within the function
  uDATA_TIER=$1
  uPREFIX=$2
  uHOST=$3
  uPORT=$4
  uDBASE=$5

  # Setup the search path: permitting the data users to see each other
  psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uDATA_TIER set search_path = ${uPREFIX}_INT, ${uPREFIX}_EXT, ${uPREFIX}_SHR;"

  # Grant usage on the data schemas to the data user
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_INT to $uDATA_TIER;"
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_EXT to $uDATA_TIER;"
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_SHR to $uDATA_TIER;"

  # Grant all on data user's own schema
  psql $uDBASE -h $uHOST -p $uPORT -c "grant all on schema $uDATA_TIER to $uDATA_TIER;"
}

function ASSIGN_EXT_DATA_PRIVS
{
  # Assign the variables within the function
  uDATA_TIER=$1
  uPREFIX=$2
  uHOST=$3
  uPORT=$4
  uDBASE=$5

  # Setup the search path: permitting the data users to see each other
  psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uDATA_TIER set search_path = ${uPREFIX}_EXT, ${uPREFIX}_INT, ${uPREFIX}_SHR;"

  # Grant usage on the data schemas to the data user
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_INT to $uDATA_TIER;"
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_EXT to $uDATA_TIER;"
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_SHR to $uDATA_TIER;"

  # Grant all on data user's own schema
  psql $uDBASE -h $uHOST -p $uPORT -c "grant all on schema $uDATA_TIER to $uDATA_TIER;"
}

function ASSIGN_SHR_DATA_PRIVS
{
  # Assign the variables within the function
  uDATA_TIER=$1
  uPREFIX=$2
  uHOST=$3
  uPORT=$4
  uDBASE=$5

  # Setup the search path: permitting the data users to see each other
  psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uDATA_TIER set search_path = ${uPREFIX}_SHR, ${uPREFIX}_INT, ${uPREFIX}_EXT, hstore, crypto;"

  # Grant usage on the data schemas to the data user
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_INT to $uDATA_TIER;"
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_EXT to $uDATA_TIER;"
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_SHR to $uDATA_TIER;"

  # Grant all on data user's own schema
  psql $uDBASE -h $uHOST -p $uPORT -c "grant all on schema $uDATA_TIER to $uDATA_TIER;"

 # Grant create on database to allow the builds to drop and recreate schema
 psql $uDBASE -h $uHOST -p $uPORT -c "grant create on database $uDBASE to $uDATA_TIER;"

 # Grant access to the crypto schema
 psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema crypto to $uDATA_TIER;"
}

function ASSIGN_JBPM_DATA_PRIVS
{
  # Assign the variables within the function
  uDATA_TIER=$1
  uPREFIX=$2
  uHOST=$3
  uPORT=$4
  uDBASE=$5

  # Grant all on data user's own schema
  psql $uDBASE -h $uHOST -p $uPORT -c "grant all on schema $uDATA_TIER to $uDATA_TIER;"

 # Grant create on database to allow the builds to drop and recreate schema
 psql $uDBASE -h $uHOST -p $uPORT -c "grant create on database $uDBASE to $uDATA_TIER;"
}

function ASSIGN_DAT_DATA_PRIVS
{
  # Assign the variables within the function
  uDATA_TIER=$1
  uPREFIX=$2
  uHOST=$3
  uPORT=$4
  uDBASE=$5

  # Setup the search path: permitting the data users to see each other
  psql $uDBASE -h $uHOST -p $uPORT -c "alter role $uDATA_TIER set search_path = ${uPREFIX}_DATA;"

  # Grant usage on the data schemas to the data user
  psql $uDBASE -h $uHOST -p $uPORT -c "grant usage on schema ${uPREFIX}_DATA to $uDATA_TIER;"

  # Grant all on data user's own schema
  psql $uDBASE -h $uHOST -p $uPORT -c "grant all on schema $uDATA_TIER to $uDATA_TIER;"

 # Grant create on database to allow the builds to drop and recreate schema
 psql $uDBASE -h $uHOST -p $uPORT -c "grant create on database $uDBASE to $uDATA_TIER;"
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
# and create the appropriate privileges to match
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

  printf "PROGRESS:   Processing: %s\n" $USER_TIER
  ASSIGN_USER_PRIVS $USER_TIER $USERNAME $HOST $PORT $DBASE $NUM_TIER

  printf "PROGRESS:   Processing: %s\n" $APPS_TIER
  ASSIGN_APPS_PRIVS $APPS_TIER $USERNAME $HOST $PORT $DBASE $NUM_TIER

  if [ $NUM_TIER -eq 6 ]
  then

    printf "PROGRESS:   Processing: %s\n" $INT_TIER
    ASSIGN_INT_DATA_PRIVS $INT_TIER $USERNAME $HOST $PORT $DBASE

    printf "PROGRESS:   Processing: %s\n" $EXT_TIER
    ASSIGN_EXT_DATA_PRIVS $EXT_TIER $USERNAME $HOST $PORT $DBASE

    printf "PROGRESS:   Processing: %s\n" $SHR_TIER
    ASSIGN_SHR_DATA_PRIVS $SHR_TIER $USERNAME $HOST $PORT $DBASE

    printf "PROGRESS:   Processing: %s\n" $JBPM_TIER
    ASSIGN_JBPM_DATA_PRIVS $JBPM_TIER $USERNAME $HOST $PORT $DBASE

  else

    printf "PROGRESS:   Processing: %s\n" $DATA_TIER
    ASSIGN_DAT_DATA_PRIVS $DATA_TIER $USERNAME $HOST $PORT $DBASE

  fi

done
