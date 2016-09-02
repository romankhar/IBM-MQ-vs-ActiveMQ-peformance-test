#!/bin/bash

#
# DESCRIPTION:
# 	This script creates a list of ActiveMQ servers in a variable ('broker1 broker2 broker3' etc) and maps them to disk path and also creates variable with port numbers
#   More details here: http://whywebsphere.com/2014/03/13/websphere-mq-and-apache-activemq-performance-comparison-part-1/
#
# RETURNED VALUES:
#   0  - Execution completed successfully
#   1  - Something went wrong
#
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
source $PROJECT_DIR/utils.sh

# When using new version of ActiveMQ do not forget to update the file /home/roman/apache-activemq-5.11.0/bin/env - by adding ACTIVEMQ_OPTS
ACTIVEMQ_JAR=activemq-all-5.11.0.jar

# How many total ActiveMQ brokers do I run in one OS instance
NUM_AMQ_SERVERS=2
#NUM_AMQ_SERVERS=4

# How many DISKS do I have in the system
MAX_DISK=1

# Port definitions
PORT_PREFIX=616		# usually full port by default is 61616
PORT_POSTFIX=6
JETTY_PORT_BASE=816   # full port is like 8161

# This is where data directories will mount (i.e. all DISKS must be mounted started from here
INSTANCE_BASE=/SSD1
#home/roman/amq

if [ $NUM_AMQ_SERVERS -gt 9 ]; then
	echo_my "'$BASH_SOURCE': if number of servers per OS is greater than 9 -> port calculations in this script will not work and need to be updated to prevent ports with numbers like 616106 (note 10 in the middle) - max port number on Linux is 65535" $ECHO_ERROR
	exit 1
fi

for ((i=1; i<=$NUM_AMQ_SERVERS; i++)); do
   if [ $i -gt 1 ]; then
	LIST_AMQ_MANAGERS="$LIST_AMQ_MANAGERS broker$i"
	LIST_AMQ_PORTS="$LIST_AMQ_PORTS $PORT_PREFIX${i}$PORT_POSTFIX"
   else
	# List of WMQ Queue Managers to connect to - these numbers will be appended to the PERF name (i.e. PERF0, PERF1, etc.) and to the port number (i.e. xxx0, xxx1, etc.)
	# At the very least we have one QM (started with 0)
	LIST_AMQ_MANAGERS="broker$i"
	
	# List of ports for AMQ servers to connect to - please note that my port calculation wont work if you want more than 9 instances
	# If you want more than 10 instances - change the math
	LIST_AMQ_PORTS="$PORT_PREFIX${i}$PORT_POSTFIX"
   fi
   DISK_NUM=$(( $(( $(( $i - 1 )) % $MAX_DISK )) + 1))
   eval INSTANCE${i}_PATH=$INSTANCE_BASE/DISK$DISK_NUM/broker$i
done

# DEBUG
echo_my "NUM_AMQ_SERVERS='$NUM_AMQ_SERVERS'" $ECHO_DEBUG
echo_my "LIST_AMQ_MANAGERS='$LIST_AMQ_MANAGERS'" $ECHO_DEBUG
echo_my "LIST_AMQ_PORTS='$LIST_AMQ_PORTS'" $ECHO_DEBUG

# DEBUG
for ((i=1; i<=$NUM_AMQ_SERVERS; i++)); do
   eval ttt=\$INSTANCE${i}_PATH
   echo_my "Instance Path $i='$ttt'" $ECHO_DEBUG
done