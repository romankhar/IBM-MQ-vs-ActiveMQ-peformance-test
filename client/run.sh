#!/bin/bash

#
# DESCRIPTION:
# 	This script calls IBM Performance Harness for JMS in various configurations
#   More details here: http://whywebsphere.com/2014/03/13/websphere-mq-and-apache-activemq-performance-comparison-part-1/
#
# CAVEATS/WARNINGS:
# 	You need to put prfharness12.jar in the same directory as this script
#
# RETURNED VALUES:
#   0  - Execution completed successfully
#   1  - Something went wrong
#
# AUTHOR:   	
#	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

set -o nounset
set -o errexit

source perfharness.sh

echo_my "***********************************************************************" $ECHO_NO_PREFIX
echo_my "Begin '$BASH_SOURCE'..."
echo_my "Visit my blog for details about this script: http://WhyWebSphere.com"
echo_my "***********************************************************************" $ECHO_NO_PREFIX
echo "------- Test run: `uname -a`" >> $RESULTS_FILE
echo "-------> Start of test run: `date`" >> $RESULTS_FILE

echo_my "Cleaning log directory - it is OK if there is an error while doing it..." $ECHO_DEBUG
mkdir $LOG_DIR | true
rm -f $LOG_DIR/* | true
rm -f $RESULTS_FILE | true

echo_my "Copying project files to remote servers so that we are on the same version of scripts across all machines..."
../copy_project.sh

echo_my "Before we do anything, lets start recording CPU usage on the client..." $ECHO_DEBUG
../activity_recorder.sh

echo_my "Now we can start the test..." $ECHO_DEBUG
for RUNTIME in $LIST_OF_SERVERS; do
	for TEST in $LIST_OF_TEST_TYPES; do
	
		echo_my "Preparing target server to run the test..." $ECHO_DEBUG
		# this function will also start Responders for the current set of tests - also will restart servers
		prepareTargetServerHost $RUNTIME $TEST
		
		for MSG_SIZE in $LIST_OF_MSG_SIZES; do
			for i in `seq 1 $REPEATS`; do 
				# Before we run the test, need to cleanup all queues from any old stuff
				cleanupQueues $RUNTIME
				# We  measure requestor times, but responders need to be started on the server in advance
				runParallelClients $REQUESTOR $RUNTIME $TEST $MSG_SIZE $i
			done
		done		
	done  
done
echo "<------- Success - end of test run: `date`" >> $RESULTS_FILE

# now call the script to aggregate the results
./beautify.sh

echo_my "***********************************************************************" $ECHO_NO_PREFIX
echo_my "Success: '$BASH_SOURCE' script is done."
echo_my "***********************************************************************" $ECHO_NO_PREFIX