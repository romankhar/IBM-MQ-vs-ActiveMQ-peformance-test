#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script deletes all existing queue managers
#
# RETURNED VALUES:
#   0  - Install completed successfully
#   1  - Something went wrong

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

source /home/roman/mom_performance/hosts.sh
source setenv_mq.sh
source ../utils.sh
source functions.sh
source list_servers.sh

echo_my ""
echo_my "------------------------------------------------------------------------------"
echo_my " This script will configure WebSphere MQ for performance test"
echo_my " Read more about this script here: http://WhyWebSphere.com"
echo_my " Today's date: `date`"
echo_my " Here are the default values used in the script (feel free to change these):"
echo_my "   WebSphere MQ Install Path: '$WMQ_INSTALL_DIR'"
echo_my "------------------------------------------------------------------------------"
echo_my ""

for i in $LIST_WMQ_MANAGERS 
do
	echo_my " QM 'PERF$i'..."
	RemoveQueueManager PERF$i
done

echo_my "-------------------------------------------------------------------------------"
echo_my " SUCCESS: WMQ setup is complete."
echo_my "-------------------------------------------------------------------------------"
