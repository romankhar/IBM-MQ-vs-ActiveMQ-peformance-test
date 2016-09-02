#!/bin/bash

# NAME:		cleanup_queues
# VERSION:	1.11
# DATE:		March 21, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script cleans all queues by calling "q" support pack to remove any and all existing messages on all queues
#
# PREREQUISITES:
#	This script requires that WMQ support pack "MA01: WebSphere MQ Q PROGRAM" is installed
#
#   http://WhyWebSphere.com
#

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

source setenv.sh
source ../utils.sh
source list_servers.sh

OLD_MSGS=cleanup_queues.log
MAX_Q_NUM=20

echo_my "Begin '$BASH_SOURCE' script..."
echo "------- Cleaning old messages: `date`" >> $OLD_MSGS

for QM in $LIST_WMQ_MANAGERS; do
	echo "------- Cleaning old messages for QM 'PERF$QM'" >> $OLD_MSGS
	for Q in `seq 1 $MAX_Q_NUM`; do
		echo "------- Cleaning old messages for 'REQUEST$Q'" >> $OLD_MSGS
		q -m PERF$QM -I REQUEST$Q >> $OLD_MSGS
		echo "------- Cleaning old messages for 'REPLY$Q'" >> $OLD_MSGS
		q -m PERF$QM -I REPLY$Q >> $OLD_MSGS
	done  
done
echo "<------- End of cleanup" >> $OLD_MSGS
echo_my "The '$BASH_SOURCE' script is done."
