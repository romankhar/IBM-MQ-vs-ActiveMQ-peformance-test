#!/bin/bash

source setenv.sh
source ../utils.sh
source list_servers.sh

COUNTER=1

for i in $LIST_AMQ_MANAGERS 
do
    echo_my "--------------> Stopping server '$i'..."
	eval INSTANCE_PATH=\$INSTANCE${COUNTER}_PATH
	$INSTANCE_PATH/bin/$i stop
	COUNTER=$[COUNTER + 1]
    echo_my "<-------------> Server '$i' has been stopped."
done
