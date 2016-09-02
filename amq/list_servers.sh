#!/bin/bash

# NAME:		list_servers
# VERSION:	1.19
# DATE:		March 20, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script creates a list of ActiveMQ servers in a variable ('broker1 broker2 broker3' etc) and maps them to disk path and also creates variable with port numbers
#   More details here: http://whywebsphere.com/2014/03/13/websphere-mq-and-apache-activemq-performance-comparison-part-1/
#
# RETURNED VALUES:
#   0  - Execution completed successfully
#   1  - Something went wrong

source ../utils.sh

# How many total ActiveMQ brokers do I run in one OS instance
NUM_AMQ_SERVERS=4

# List of WMQ Queue Managers to connect to - these numbers will be appended to the PERF name (i.e. PERF0, PERF1, etc.) and to the port number (i.e. xxx0, xxx1, etc.)
# At the very least we have one QM (started with 0)
LIST_AMQ_MANAGERS="broker1"

# List of ports for AMQ servers to connect to - please note that my port calculation wont work if you want more than 9 instances
# If you want more than 10 instances - change the math
LIST_AMQ_PORTS="61616"
INSTANCE1_PATH=/media/SSD1/broker1

if [ $NUM_AMQ_SERVERS -gt 9 ]; then
	echo_my "'$BASH_SOURCE': if number of servers per OS is greater than 9 -> port calculations in this script will not work and need to be updated to prevent ports with numbers like 616106 (note 10 in the middle) - max port number on Linux is 65535" $ECHO_ERROR
	exit 1
fi

# How many DISKS do I have in the system
MAX_SSD=4

for ((i=2; i<=$NUM_AMQ_SERVERS; i++)); do
   LIST_AMQ_MANAGERS="$LIST_AMQ_MANAGERS broker$i"
   LIST_AMQ_PORTS="$LIST_AMQ_PORTS 616${i}6"
   SSD_NUM=$(( $(( $(( $i - 1 )) % $MAX_SSD )) + 1))
   eval INSTANCE${i}_PATH=/media/SSD$SSD_NUM/broker$i
done

# DEBUG
echo_my "NUM_AMQ_SERVERS='$NUM_AMQ_SERVERS'" $ECHO_DEBUG
echo_my "LIST_AMQ_MANAGERS=$LIST_AMQ_MANAGERS" $ECHO_DEBUG
echo_my "LIST_AMQ_PORTS=$LIST_AMQ_PORTS" $ECHO_DEBUG

# DEBUG
for ((i=1; i<=$NUM_AMQ_SERVERS; i++)); do
   eval ttt=\$INSTANCE${i}_PATH
   echo_my "Instance Path $i = $ttt" $ECHO_DEBUG
done

