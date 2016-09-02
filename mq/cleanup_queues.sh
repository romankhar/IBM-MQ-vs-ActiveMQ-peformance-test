#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
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

source /home/roman/mom_performance/hosts.sh
source $PROJECT_DIR/client/setenv_client.sh
source setenv_mq.sh
source $PROJECT_DIR/utils.sh
source list_servers.sh

echo_my "Begin '$BASH_SOURCE' script..."

OLD_MSGS=cleanup_queues.log
echo_my "MAX_Q_NUM=$MAX_Q_NUM"

echo "------- Cleaning old messages: `date`" >> $OLD_MSGS

for QM in $LIST_WMQ_MANAGERS; do
	echo "------- Cleaning old messages for QM 'PERF$QM'" >> $OLD_MSGS
	for Q in `seq 1 $MAX_Q_NUM`; do
		echo "------- Cleaning old messages for 'REQUEST$Q'" >> $OLD_MSGS
		q -m PERF$QM -I $MQ_INPUT_Q$Q >> $OLD_MSGS
		echo "------- Cleaning old messages for 'REPLY$Q'" >> $OLD_MSGS
		q -m PERF$QM -I $MQ_OUTPUT_Q$Q >> $OLD_MSGS
	done  
done
echo "<------- End of cleanup" >> $OLD_MSGS
echo_my "The '$BASH_SOURCE' script is done."
