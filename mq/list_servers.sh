#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script creates a list of WMQ servers in the environment variable (in a format of '0 1 2 3 4' etc.)
#   More details here: http://whywebsphere.com/2014/03/13/websphere-mq-and-apache-activemq-performance-comparison-part-1/

source ../utils.sh

# How many QMs total
#NUM_WMQ_SERVERS=4
NUM_WMQ_SERVERS=2

# List of WMQ Queue Managers to connect to - these numbers will be appended to the PERF name (i.e. PERF0, PERF1, etc.) and to the port number (i.e. xxx0, xxx1, etc.)
# At the very least we have one QM (started with 0)
# Do not change this value as it is automatically generated based on the $NUM_WMQ_SERVERS above
LIST_WMQ_MANAGERS="0"

for ((i=1; i<$NUM_WMQ_SERVERS; i++)); do
   LIST_WMQ_MANAGERS="$LIST_WMQ_MANAGERS $i"
done

echo_my "NUM_WMQ_SERVERS='$NUM_WMQ_SERVERS'" $ECHO_DEBUG
echo_my "LIST_WMQ_MANAGERS='$LIST_WMQ_MANAGERS'" $ECHO_DEBUG
