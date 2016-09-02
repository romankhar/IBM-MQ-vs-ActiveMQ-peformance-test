#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)

source setenv_mq.sh
source ../utils.sh
source list_servers.sh

for i in $LIST_WMQ_MANAGERS 
do
	echo_my "Initiating start of WMQ QM 'PERF$i'..."
	/opt/mqm/bin/strmqm PERF$i &
done
