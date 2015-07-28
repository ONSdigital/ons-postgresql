#! /bin/bash
#--------------------------------------------------------------
#
# NAME:    pgpool_failover.sh
#
# PURPOSE: Failover script for streaming replication.
#
# NOTES:   Called by pgpool, this script performs actions in
#          the event of loss of a PostgreSQL database service.
#          This script assumes that DB node 0 is primary, and
#          DB node 1 is standby.
#          If standby goes down, do nothing. If primary goes down,
#          create a trigger file so that standby takes over as the
#          primary node.
#
# ARGS:    1. Failed node id.
#          2. New master hostname.
#          3. Path to trigger file.
#
# VERSION  DATE         AUTHOR          CHANGE
# 1.0      28/08/13     S Bennett       Created

# Stream the variables out to a temporary file
# This is used mainly for debug and logging purposes
echo $1 > /tmp/pgpool_failover.params
echo $2 >> /tmp/pgpool_failover.params
echo $3 >> /tmp/pgpool_failover.params
echo $4 >> /tmp/pgpool_failover.params
echo $5 >> /tmp/pgpool_failover.params
echo $6 >> /tmp/pgpool_failover.params

# Assign the input parameters to variables
failed_node_id=$1
failed_node_name=$2
new_master_id=$3
new_master_name=$4
trigger_file=$5
old_master_id=$6

# Decide how to act in the event of a node failure
# If the failed node is the standby DO NOT initiate failover.
if [ $new_master_id == $old_master_id ]; then
        exit 0;
fi

# Create the trigger file.
su postgres -c "/usr/bin/ssh -T bennes4@$new_master_name /bin/touch $trigger_file"

#exit 0;
