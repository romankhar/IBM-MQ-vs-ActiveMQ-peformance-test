#!/bin/bash

# NAME:		mqcreate
# VERSION:	1.12
# DATE:		March 19, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script configures existing installation of WMQ by adding queue managers, queues, etc.
#
#   http://WhyWebSphere.com
#
# CAVEATS/WARNINGS:
# 	This script assumes that you already have installed WMQ.
#
# RETURNED VALUES:
#   0  - Install completed successfully
#   1  - Something went wrong

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

source setenv.sh
source ../utils.sh
source functions.sh

#############################################
# MAIN BODY starts here
#############################################
echo_my ""
echo_my "------------------------------------------------------------------------------"
echo_my " This script will configure WebSphere MQ for performance test"
echo_my " Read more about this script here: http://WhyWebSphere.com"
echo_my " Today's date: `date`"
echo_my " Here are the default values used in the script (feel free to change these):"
echo_my "   WebSphere MQ Install Path: '$WMQ_INSTALL_DIR'"
echo_my "------------------------------------------------------------------------------"
echo_my ""

# Define first instance of queue manager (repeat these lines if you need multiple QMs)
#CreateQueueManager $QM $PORT $QM_DATA_PATH $QM_LOG_PATH
CreateQueueManager PERF0 1420 /media/SSD1 /media/SSD2
CreateQueueManager PERF1 1421 /media/SSD2 /media/SSD1
CreateQueueManager PERF2 1422 /media/SSD3 /media/SSD4
CreateQueueManager PERF3 1423 /media/SSD4 /media/SSD3
#CreateQueueManager PERF4 1424 /media/SSD4 /media/SSD3
#CreateQueueManager PERF5 1425 /media/SSD3 /media/SSD2

echo_my "-------------------------------------------------------------------------------"
echo_my " SUCCESS: WMQ setup is complete."
echo_my "-------------------------------------------------------------------------------"
