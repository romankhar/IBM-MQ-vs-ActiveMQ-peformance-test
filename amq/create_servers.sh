#!/bin/bash

#
# DESCRIPTION:  This script creates messaging servers
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

source setenv_amq.sh
source ../utils.sh
source list_servers.sh

echo_my "AMQ_INSTALL_DIR='$AMQ_INSTALL_DIR'"
echo_my "LIST_AMQ_MANAGERS='$LIST_AMQ_MANAGERS'"

./remove_servers.sh

COUNTER=1

for i in $LIST_AMQ_MANAGERS 
do
	echo_my "-----------------> Creating server #$COUNTER, instance name '$i'..."
	eval INSTANCE_PATH=\$INSTANCE${COUNTER}_PATH
	echo_my "INSTANCE_PATH='$INSTANCE_PATH'"
	set +u
	set +e
	$AMQ_INSTALL_DIR/bin/activemq create $INSTANCE_PATH
        RC=$?
	set -u
	set -e
        if [ $RC = 1 ]; then
                echo_my "<----------------- Success, server path = '$INSTANCE_PATH'"
        else
                echo_my "Error while creating new server RC='$RC'" $ECHO_ERROR
                exit 1
        fi
        
        # Copy config files to a new location - erasing the default generated files
        cp amq_template.xml $INSTANCE_PATH/conf/activemq.xml
        cp jetty_template.xml $INSTANCE_PATH/conf/jetty.xml
         
	COUNTER=$[COUNTER + 1]
done

echo_my "Done. All servers have been created."