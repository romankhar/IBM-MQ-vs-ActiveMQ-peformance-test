#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script configures existing installation of WMQ by adding queue managers, queues, etc.
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

source /home/roman/mom_performance/hosts.sh
source ../client/setenv_client.sh
source setenv_mq.sh
source ../utils.sh
source functions.sh
source list_servers.sh

########################################################################################
# Create directory for MQ data or log
# 1 - dir path (i.e. /mq_data)
# 2 - user to own it
# 3 - group to own it
########################################################################################
create_dir(){
echo_my "Creating directories - if you see errors - do not worry, this is expected when run more then once..."
	sudo mkdir $1 | true
	sudo chmod 777 $1 | true
	sudo chown $2 $1 | true
	sudo chgrp $3 $1 | true
}

########################################################################################
# Create queue definitions
# 1 - # of input queues (same as # of output queues
# 2 - file name for the output
########################################################################################
create_q_definitions(){
	echo_my "Creating Queue definitions..."
	rm -rf $2 | true		# remove the old file
	for ((i=1; i<=$1; i++)); do
	   echo "define qlocal(${MQ_INPUT_Q}${i}) maxdepth($MAX_DEPTH)" >> $2
	   echo "define qlocal(${MQ_OUTPUT_Q}${i}) maxdepth($MAX_DEPTH)" >> $2
	done
}

########################################################################################
# Main
########################################################################################
echo_my ""
echo_my "------------------------------------------------------------------------------"
echo_my " This script will configure WebSphere MQ for performance test"
echo_my " Read more about this script here: http://WhyWebSphere.com"
echo_my " Today's date: `date`"
echo_my " Here are the default values used in the script (feel free to change these):"
echo_my "   WebSphere MQ Install Path: '$WMQ_INSTALL_DIR'"
echo_my "------------------------------------------------------------------------------"
echo_my ""

create_dir $BASE_DATA_DIR $REMOTE_USER mqm
create_dir $BASE_LOG_DIR $REMOTE_USER mqm

# now we shall add the performance user - this guy will have access to the queues
./add_user.sh | true

create_q_definitions $MAX_Q_NUM $Q_DEFINITION_FILE

for i in $LIST_WMQ_MANAGERS 
do
	echo_my " QM 'PERF$i'..."
	#CreateQueueManager $QM $PORT $QM_DATA_PATH $QM_LOG_PATH
	CreateQueueManager PERF$i 142$i $BASE_DATA_DIR $BASE_LOG_DIR
done

#CreateQueueManager PERF0 1420 $BASE_DATA_DIR $BASE_LOG_DIR
#CreateQueueManager PERF1 1421 $BASE_DATA_DIR $BASE_LOG_DIR
#CreateQueueManager PERF2 1422 $BASE_DATA_DIR $BASE_LOG_DIR
#---for the last one we will put its logs on HDD and data on SSD
#CreateQueueManager PERF3 1423 $BASE_LOG_DIR $BASE_DATA_DIR

#CreateQueueManager PERF1 1421 /media/SSD2 /media/SSD1
#CreateQueueManager PERF2 1422 /media/SSD3 /media/SSD4
#CreateQueueManager PERF3 1423 /media/SSD4 /media/SSD3
#CreateQueueManager PERF4 1424 /media/SSD4 /media/SSD3
#CreateQueueManager PERF5 1425 /media/SSD3 /media/SSD2

echo_my "-------------------------------------------------------------------------------"
echo_my " SUCCESS: WMQ setup is complete."
echo_my "-------------------------------------------------------------------------------"
