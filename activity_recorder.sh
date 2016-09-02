#!/bin/bash

#
# DESCRIPTION: 	This script records I/O and CPU activity on the local host and can be called from remote host
# 				The activity is recorded into a file for analysis in the future and mapping CPU usage to test cases
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

source /home/roman/mom_performance/utils.sh

REFRESH_RATE=5
OUTPUT_FILE=activity_recorder.log

echo_my "Kill any existing iostat instances..." $ECHO_DEBUG
kill -9 $(ps aux | grep '[i]ostat' | awk '{print $2}') | true

echo_my "Start recording CPU and disk usage into the file '$OUTPUT_FILE'..."
nohup iostat -t -z -m $REFRESH_RATE > $OUTPUT_FILE 2> $OUTPUT_FILE < /dev/null &


#OUTPUT_FILE_VM=activity_recorder.vmstat.log
#echo "Kill any existing vmstat instances..."
#kill -9 $(ps aux | grep '[v]mstat' | awk '{print $2}')
#echo "--- INFO: Starting vmstat recording into file '$OUTPUT_FILE_VM'..."
#vmstat -t $REFRESH_RATE >> $OUTPUT_FILE_VM &