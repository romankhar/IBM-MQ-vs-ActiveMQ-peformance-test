#!/bin/bash

source setenv.sh
source ../utils.sh
source list_servers.sh

COUNTER=1

for i in $LIST_AMQ_MANAGERS 
do
	echo_my "------------> Starting AMQ server '$i'..."
	eval INSTANCE_PATH=\$INSTANCE${COUNTER}_PATH
	echo_my "INSTANCE_PATH=$INSTANCE_PATH" $ECHO_DEBUG
	$INSTANCE_PATH/bin/$i start
	COUNTER=$[COUNTER + 1]
	echo_my "<---------- AMQ Server '$i' has been started."
done
