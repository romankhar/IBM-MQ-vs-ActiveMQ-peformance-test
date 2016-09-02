#!/bin/bash

source setenv.sh
source ../utils.sh
source list_servers.sh

for i in $LIST_WMQ_MANAGERS 
do
	echo_my "Initiating stop of WMQ QM 'PERF$i'..."
	/opt/mqm/bin/endmqm PERF$i &
done
