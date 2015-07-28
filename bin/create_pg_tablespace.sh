#!/bin/bash
#--------------------------------------------------------------
#
# NAME:    create_pg_tablespace.sh
#
# PURPOSE: Creates a tablespace within a PostgreSQL database
#
# NOTES:   Conforms to OTS standards of supplying a list file
#          of tablespace names allowing multiple tbs to be created.
#
# ARGS:    1. Full path of list file.
#          2. Host where the PostgreSQL server is running.
#          3. Port that the PostgreSQL service is listening on.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      05/08/13     S Bennett       Created
#--------------------------------------------------------------


#--------------------------------------------------------------
# This function creates a tablespace.
# It can be called multiple times from the main routine.
#--------------------------------------------------------------
function CREATE_PG_TBS
{
  # Assign the variables within the function
  dTBSNAME=$1
  dHOST=$2
  dPORT=$3

  # Create the tablespace - connect to the postgres database
  # when connecting in order to create a new tbs.
  psql postgres -h $dHOST -p $dPORT -c "create tablespace $dTBSNAME LOCATION '/u02/app/postgres/pgtablespace_$dPORT'"

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
if [ $# -ne 3 ]
then
  printf "\nUSAGE: %s <filename> <host> <port>\n" $0
  exit 2
fi

# Assign the argument to a more descriptive variable name
LIST_FILE=$1
HOST=$2
PORT=$3

# Check that the file name passed in exists as a file
if [ ! -f $LIST_FILE ]
then
  printf "\nERROR: File %s does not exist\n" $LIST_FILE
  exit 3
fi

printf "\nPROGRESS: Using list file: %s\n" $LIST_FILE

# This loop will process each name (row) in the $LIST_FILE
# and create the appropriate databases to match
for TBSNAME in `grep -v '^#' $LIST_FILE`
do
  printf "\nPROGRESS: Using list file: %s\n" $TBSNAME

  printf "PROGRESS:   Creating Tablespce: %s\n" $TBSNAME
  CREATE_PG_TBS $TBSNAME $HOST $PORT

done
