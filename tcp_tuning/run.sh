#!/bin/bash

# VERSION:	1.13
# DATE:		March 17, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script is to be used for Linux TCP tuning on RHEL.
#
#   http://WhyWebSphere.com
#

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit


#############################################
# MAIN BODY starts here
#############################################
echo ""
echo "------------------------------------------------------------------------------"
echo " This script will tune TCP parameters on multiple RHEL hosts and test network performance"
echo "------------------------------------------------------------------------------"
echo ""

# Propagate latest scripts to remote hosts
echo "Copy project files to remote  hosts ........................"
../copy_project.sh

# Run tuning on the local host
TUNER_COMMAND=tcp_settings.sh
sudo ./$TUNER_COMMAND

# Tune remote hosts
LIST_OF_HOSTS="amqhost"
#LIST_OF_HOSTS="amqhost mqhost"

IPERF_OPTIONS="-m -w64K"
IPERF=start_tcp_perf.sh

for HOST in $LIST_OF_HOSTS; do
	echo "HOST=$HOST .........................."
	
	echo "Now can run remote tuning of the host..."
	RUNTIME_DIR=/home/roman/mom_performance/tcp_tuning
	COMMAND="cd $RUNTIME_DIR; sudo ./$TUNER_COMMAND"
	ssh -t $HOST $COMMAND
	
	echo "Test if JumboFrames work ok..."
	ping amqhost -s 9000 -c 4
	
	echo "Start remote iperf instance..."
	COMMAND="cd $RUNTIME_DIR; ./$IPERF -s"
	ssh $HOST $COMMAND &
	
	sleep 1
	
	echo "Now can run the TCP test..."
	./$IPERF -c$HOST
done

echo "DONE: script $BASH_SOURCE"
