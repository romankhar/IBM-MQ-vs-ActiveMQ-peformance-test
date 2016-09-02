#!/bin/bash

source setenv.sh
source ../utils.sh
source list_servers.sh

for i in $LIST_WMQ_MANAGERS 
do
	echo_my "Initiating start of WMQ QM 'PERF$i'..."
	/opt/mqm/bin/strmqm PERF$i &
done
