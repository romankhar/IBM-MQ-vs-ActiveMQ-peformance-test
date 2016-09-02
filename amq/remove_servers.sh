#!/bin/bash

#
# DESCRIPTION: This script removes and cleans all messaging servers
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
source setenv_amq.sh
source ../utils.sh
source list_servers.sh

echo_my "AMQ_INSTALL_DIR='$AMQ_INSTALL_DIR'"
echo_my "LIST_AMQ_MANAGERS='$LIST_AMQ_MANAGERS'"

#set +u
#set +e
# first stop all running brokers
./stop_all.sh | true
#set -u
#set -e

COUNTER=1

for i in $LIST_AMQ_MANAGERS 
do
	echo_my "-----------------> removing server #$COUNTER, instance name '$i'..."
	eval INSTANCE_PATH=\$INSTANCE${COUNTER}_PATH
	echo_my "INSTANCE_PATH='$INSTANCE_PATH'"
#	set +u
#	set +e
	# remove old directories for cleaneness
	rm -rf $INSTANCE_PATH
#	set -u
#	set -e
         
	COUNTER=$[COUNTER + 1]
done

echo_my "All servers have been removed" $ECHO_WARNING