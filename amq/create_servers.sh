#!/bin/bash

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
#set -o nounset
# This automatically exits the script if any error occurs while running it
#set -o errexit

source setenv.sh
source ../utils.sh
source list_servers.sh

echo_my $AMQ_HOME
COUNTER=1

for i in $LIST_AMQ_MANAGERS 
do
	echo_my "-----------------> Creating server #$COUNTER, instance name '$i'..."
	eval INSTANCE_PATH=\$INSTANCE${COUNTER}_PATH
	$AMQ_HOME/bin/activemq create $INSTANCE_PATH
        RC=$?
        if [ $RC = 1 ]; then
                echo_my "<----------------- Success, server path = '$INSTANCE_PATH'"
        else
                echo_my "Error while creating new server RC='$RC'" $ECHO_ERROR
                exit 1
        fi
	COUNTER=$[COUNTER + 1]
done

echo_my "REMEMBER to manually update jetty.xml and activemq.xml files in the 'conf' directory to avoid port conflicts (!!!)" $ECHO_WARNING

