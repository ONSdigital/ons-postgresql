#!/bin/bash
#--------------------------------------------------------------
#
# NAME:    create_pg_db.sh
#
# PURPOSE: Creates a PostgreSQL daabase to OTS specification
#          within the PostgreSQL service.
#
# NOTES:   Conforms to OTS standards of supplying a list file
#          of database names allowing multiple dbs to be created.
#
# ARGS:    1. Full path of list file.
#          2. Host where the PostgreSQL server is running.
#          3. Port that the PostgreSQL service is listening on.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      08/07/13     S Bennett       Created
#--------------------------------------------------------------


#--------------------------------------------------------------
# This function creates a database.
# It can be called multiple times from the main routine.
#--------------------------------------------------------------
function CREATE_PG_DB
{
  # Assign the variables within the function
  dDBNAME=$1
  dHOST=$2
  dPORT=$3
  dTBSNAME=$4

  # Create the database - connect to the postgres database
  # when connecting in order to create a new db.
  psql postgres -h $dHOST -p $dPORT -c "create database $dDBNAME tablespace $dTBSNAME"

  # Connect to the new database and remove the public schema
  psql $dDBNAME -h $dHOST -p $dPORT -c "drop schema public"

  # Connect to the new database and create a schema for the hstore extension
  psql $dDBNAME -h $dHOST -p $dPORT -c "create schema hstore"

  # Connect to the new database and install the hstore extension
  psql $dDBNAME -h $dHOST -p $dPORT -c "create extension hstore schema hstore"

  # Connect to the new database and create a schema for the crypto extension
  psql $dDBNAME -h $dHOST -p $dPORT -c "create schema crypto"

  # Connect to the new database and install the pgcrypto extension
  psql $dDBNAME -h $dHOST -p $dPORT -c "create extension pgcrypto schema crypto"

  # Connect to the new database and create a schema for the pg_buffercache extension
  psql $dDBNAME -h $dHOST -p $dPORT -c "create schema ots_admin"

  # Connect to the new database and install the pg_buffercache extension
  psql $dDBNAME -h $dHOST -p $dPORT -c "create extension pg_buffercache schema ots_admin"

  # Give the pgagent user permissions on the database
  psql $dDBNAME -h $dHOST -p $dPORT -c "grant connect on database $dDBNAME to pgagent"
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
TBSNAME=$4

# Check that the file name passed in exists as a file
if [ ! -f $LIST_FILE ]
then
  printf "\nERROR: File %s does not exist\n" $LIST_FILE
  exit 3
fi

printf "\nPROGRESS: Using list file: %s\n" $LIST_FILE

# This loop will process each name (row) in the $LIST_FILE
# and create the appropriate databases to match
for ROW in `grep -v '^#' $LIST_FILE`
do
  DBNAME=`echo $ROW | cut -d: -f1`
  TBSNAME=`echo $ROW | cut -d: -f2`

  printf "\nPROGRESS: Using list file: %s\n" $DBNAME

  printf "PROGRESS:   Creating Database: %s\n" $DBNAME
  CREATE_PG_DB $DBNAME $HOST $PORT $TBSNAME

done
