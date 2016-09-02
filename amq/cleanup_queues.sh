#!/bin/bash

#
# DESCRIPTION:	This script purges all messages from all queues
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

set -o nounset
set -o errexit

source /home/roman/mom_performance/hosts.sh
source $PROJECT_DIR/client/setenv_client.sh
source setenv_amq.sh
source $PROJECT_DIR/utils.sh
source list_servers.sh

echo_my "Begin '$BASH_SOURCE' script..."

OLD_MSGS=cleanup_queues.log
echo_my "MAX_Q_NUM=$MAX_Q_NUM"

echo "------- Cleaning old messages: `date`" >> $OLD_MSGS

COUNTER=1

for i in $LIST_AMQ_MANAGERS 
do
	echo_my "--------------> Purging messages from server '$i'..."
	eval INSTANCE_PATH=\$INSTANCE${COUNTER}_PATH
	$INSTANCE_PATH/bin/$i purge
	COUNTER=$[COUNTER + 1]
	echo_my "<------------- Messages for '$i' have been purged"
done

echo "<------- End of queues cleanup" >> $OLD_MSGS
echo_my "The '$BASH_SOURCE' script is done."