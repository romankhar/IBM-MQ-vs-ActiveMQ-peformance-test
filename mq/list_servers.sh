#!/bin/bash

# NAME:		list_servers
# VERSION:	1.19
# DATE:		March 20, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script creates a list of WMQ servers in the environment variable (in a format of '0 1 2 3 4' etc.)
#   More details here: http://whywebsphere.com/2014/03/13/websphere-mq-and-apache-activemq-performance-comparison-part-1/

source ../utils.sh

NUM_WMQ_SERVERS=4

# List of WMQ Queue Managers to connect to - these numbers will be appended to the PERF name (i.e. PERF0, PERF1, etc.) and to the port number (i.e. xxx0, xxx1, etc.)
# At the very least we have one QM (started with 0)
LIST_WMQ_MANAGERS="0"

for ((i=1; i<$NUM_WMQ_SERVERS; i++)); do
   LIST_WMQ_MANAGERS="$LIST_WMQ_MANAGERS $i"
done

echo_my "NUM_WMQ_SERVERS='$NUM_WMQ_SERVERS'" $ECHO_DEBUG
echo_my "LIST_WMQ_MANAGERS='$LIST_WMQ_MANAGERS'" $ECHO_DEBUG
