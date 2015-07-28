#!/bin/bash
#--------------------------------------------------------------
#
# NAME:    take_edc_baseline.sh
#
# PURPOSE: Creates a new edc baseline of the schemas using a
#          schema only export.
#
# NOTES:   Takes a parameter file as input with list of schemas
#          to export.
#          Will export to the standard export location on disk.
#
# ARGS:    1. Full path of list file.
#          2. Host where the PostgreSQL server is running.
#          3. Port that the PostgreSQL service is listening on.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      23/07/15     S Bennett       Created
#--------------------------------------------------------------


#--------------------------------------------------------------
# This function creates a database.
# It can be called multiple times from the main routine.
#--------------------------------------------------------------
function EXPORT_PG_SCHEMA
{
  # Assign the variables within the function
  dDBNAME=$1
  dHOST=$2
  dPORT=$3
  dSCHEMA=$4

  DUMPDIR=/u01/app/postgres/pg_dump_dir
  EXPORTDATE=`date +%d%m%y%H%M%S`
  DUMPFILE=${DUMPDIR}/${dSCHEMA}_${EXPORTDATE}.sql

  #Export the schema
  pg_dump -s -h $dHOST -p $dPORT -n $dSCHEMA $dDBNAME -f $DUMPFILE
  printf "\n PROGRESS: %s\n" $DUMPFILE
  
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

# Assign the arguments to more descriptive variable names
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

# This loop will process each schema name (row) in the $LIST_FILE
# and produce the appropriate export.
for ROW in `grep -v '^#' $LIST_FILE`
do
   SCHEMA=`echo $ROW | cut -d: -f1`
   DBNAME=`echo $ROW | cut -d: -f2`

   printf "\nPROGRESS: Exporting Schema: %s from Database: %s\n" $SCHEMA $DBNAME
   EXPORT_PG_SCHEMA $DBNAME $HOST $PORT $SCHEMA
done
