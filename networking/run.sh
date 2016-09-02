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


echo "--- This script will tune TCP parameters on multiple RHEL hosts and test network performance"
RUNTIME_DIR=/home/roman/mom_performance/networking

# Propagate latest scripts to remote hosts
echo "--- Copy project files to remote  hosts..."
../copy_project.sh

source host_list.sh

# Run tuning on the local host
TUNER_COMMAND=tcp_settings.sh
sudo ./$TUNER_COMMAND

IPERF_OPTIONS="-m -w64K"
# this script should not have 'iperf' in its name because we will later call kill -9 on anything with 'iperf' in it
IPERF=caller.sh

for HOST in $LIST_OF_HOSTS; do
	echo "--- HOST=$HOST"
	
	echo "--- Now can run remote tuning of the host..."
	COMMAND="cd $RUNTIME_DIR; sudo ./$TUNER_COMMAND"
	ssh -t $HOST $COMMAND
	
	echo "--- Test if JumboFrames work ok..."
	ping amqhost -s 9000 -c 4
	
	echo "--- Start remote iperf instance..."
	COMMAND="cd $RUNTIME_DIR; ./$IPERF -s"
	ssh $HOST $COMMAND &
	
	sleep 1
	
	echo "--- Now can run the TCP test..."
	./$IPERF -c$HOST
done

echo "--- DONE: script $BASH_SOURCE"
