#!/bin/bash

# NAME:		perfharness 
# VERSION:	1.24
# DATE:		March 31, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script calls IBM Performance Harness for JMS in various configurations
#
#   More details here: http://whywebsphere.com/2014/03/13/websphere-mq-and-apache-activemq-performance-comparison-part-1/
#
# CAVEATS/WARNINGS:
# 	You need to put perfharness12.jar in the same directory as this script.
#   AMQ and WMQ clients need to be installed and working for this script to work.
#
# RETURNED VALUES:
#   0  - Execution completed successfully
#   1  - Something went wrong

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

source setenv.sh
source ../utils.sh
source ../mq/list_servers.sh
source ../amq/list_servers.sh

##############################################################################
# Prepare WMQ host to run the performance test
#
# Params
# 1 - Server type
# 2 - Test type
##############################################################################
prepareTargetServerHost()
{
	echo_my "prepareTargetServerHost()..." $ECHO_DEBUG
	local SLEEP_TIME=20

	if [ $1 = $AMQ ]; then
		REMOTE_HOST=$AMQ_HOST
		RUNTIME_DIR=$BASE_DIR/../amq
	else
		REMOTE_HOST=$WMQ_HOST
		RUNTIME_DIR=$BASE_DIR/../mq
	fi
	
	echo_my "Start recording CPU and disk usage..."
	COMMAND="cd $RUNTIME_DIR; ../activity_recorder.sh"
	ssh $REMOTE_HOST "$COMMAND"

	echo_my "Stopping all remote servers..."
	COMMAND="cd $RUNTIME_DIR; ./stop_all.sh"
	ssh $REMOTE_HOST "$COMMAND"
	echo_my "Sleeping for $SLEEP_TIME sec to make sure server has shut down..."
	sleep $SLEEP_TIME
	
	echo_my "Starting remote server..."
	COMMAND="cd $RUNTIME_DIR; ./start_all.sh"
	ssh $REMOTE_HOST "$COMMAND"
	echo_my "Sleeping for $SLEEP_TIME sec to make sure server has started up..."
	sleep $SLEEP_TIME
	
	echo_my "Starting responders (must be done before starting requestors)..."
	# For responders message size does not matter as they take whatever messages from REQUEST Q and put them on REPLY Q
	# When we stopped the remote server, all responders died on their own, so we dont even have to stop them here. Can safely start new ones
	COMMAND="cd $RUNTIME_DIR/../client; nohup ./responder.sh $1 $2 > $RESPONDER_LOG 2> $RESPONDER_LOG < /dev/null &"
	ssh $REMOTE_HOST "$COMMAND"
	echo_my "Sleeping for $SLEEP_TIME sec to make sure responders started up..."
	sleep $SLEEP_TIME
}

##############################################################################
# Remove all old messages from all queues
#
# Params
# 1 - Server type
##############################################################################
cleanupQueues()
{
	echo_my "Cleaning up all queues..."

	if [ $1 = $AMQ ]; then
		REMOTE_HOST=$AMQ_HOST
		RUNTIME_DIR=$BASE_DIR/../amq
	else
		REMOTE_HOST=$WMQ_HOST
		RUNTIME_DIR=$BASE_DIR/../mq
	fi
	
	COMMAND="cd $RUNTIME_DIR; ./cleanup_queues.sh"
	ssh $REMOTE_HOST "$COMMAND"
}

##############################################################################
# Configure fast non-persistent messaging.
##############################################################################
setupQoSNonPersistent()
{
	echo_my "Configuring 'NonPersistentTest'..."
	USE_PERSISTENT_MSGS=false
	TRANSACTIONS=false
}

##############################################################################
# Configure reliable persistent transactional messaging.
##############################################################################
setupQoSPersistent()
{
	echo_my "Configuring 'PersistentTest'..."
	USE_PERSISTENT_MSGS=true
	TRANSACTIONS=true
}

##############################################################################
# This sets environment vars for the requestor and proper runtime for it
##############################################################################
setupOperationRequestor()
{
	echo_my "Configuring 'Requestor'..."
	RUN_TIME=$REQUESTOR_RUN_TIME
	REQUESTOR=jms.r11.Requestor
}

##############################################################################
# This sets environment vars for the responder and proper runtime for it
##############################################################################
setupOperationResponder()
{
	echo_my "Configuring 'Responder'..."
	RUN_TIME=$RESPONDER_RUN_TIME
	REQUESTOR=jms.r11.Responder
}

##############################################################################
# This calculates number of client threads based on the number of servers
#
# Params
# 1 - Type of server
# 2 - Type of test (persistent or not)
##############################################################################
calculateClientThreads()
{
	if [ $1 = $AMQ ]; then
		NUM_SERVERS=$NUM_AMQ_SERVERS
	fi

	if [ $1 = $WMQ ]; then
		NUM_SERVERS=$NUM_WMQ_SERVERS
	fi
	
	if [ $2 = $PERSISTENT ]; then
		TOTAL_CLIENTS=$P_CLIENT_THREADS
	fi
	
	if [ $2 = $NON_PERSISTENT ]; then
		TOTAL_CLIENTS=$NP_CLIENT_THREADS
	fi
	
	CLIENT_THREADS=$(( $TOTAL_CLIENTS / $NUM_SERVERS ))
	echo_my "CLIENT_THREADS='$CLIENT_THREADS' per instance of jmsperf" $ECHO_DEBUG
}

##############################################################################
# This sets environment vars for the WMQ client, such as bindings mode, etc.
#
# Params
# 1 - Queue Manager name
# 2 - Host name
# 3 - Port number for the server listener
##############################################################################
setupServerTypeWMQ()
{
	echo_my "Configuring 'WMQ'..."
	CLASSPATH="$CLASSPATH:$WMQ_INSTALL_DIR/java/lib/*"
	CHANNEL=SYSTEM.DEF.SVRCONN
	PROVIDER_CLASS=WebSphereMQ
	PERFORMANCE_USER=mqperf
	PERFORMANCE_USER_PW=password
	USER=" "
	PASSWORD=" "
	# local bindings set to "mqb", tcp/ip bindings set to "mqc" - depending on whether this client is running on the same host as the server
	if [ `hostname` = $HOST ]; then
		MQ_BINDINDS=mqb
	else
		MQ_BINDINDS=mqc
		# USER="-us $PERFORMANCE_USER"
		# PASSWORD="-pw $PERFORMANCE_USER_PW"
	fi
	INPUT_Q=REQUEST
	OUTPUT_Q=REPLY
	VENDOR_SPECIFIC_SETTINGS="-jb $1 -jh $2 -jp $3 -jc $CHANNEL -pc $PROVIDER_CLASS -jt $MQ_BINDINDS -jq SYSTEM.BROKER.DEFAULT.STREAM -ja $WMQ_ACKNOWLEDGEMENT_MAX_MSGS -oq $OUTPUT_Q -iq $INPUT_Q $USER $PASSWORD"	
}

##############################################################################
# This sets environment vars for the AMQ client, such as Context Factory, etc.
#
# Params
# 1 - Broker name (not used)
# 2 - Host name
# 3 - Port number for the server listener
# 4 - Operation type - requestor or responder
# 5 - Client ID (incremental for many instances)
##############################################################################
setupServerTypeAMQ()
{
	echo_my "Configuring 'AMQ'..."
	REQUESTOR_OR_RESPONDER=$4
	CLASSPATH="$CLASSPATH:$AMQ_INSTALL_DIR/activemq-all-5.9.0.jar"

	if [ $REQUESTOR_OR_RESPONDER = $RESPONDER ] && [ $AMQ_USE_VM_PROTOCOL = 'true' ]; then
		 # At certain times I seem to be having an issue with this JIRA bug: https://issues.apache.org/jira/browse/AMQ-4097
		 # "vm" protocol is not for production use, so this line below will not be used for performance tests
        JNDI_PROVIDER_URL="vm:broker:(tcp://localhost:$3,tcp://$2:$3)?persistent=true&useJmx=false"
        echo_my "'vm' protocol should not be used for production environment!!!" $ECHO_WARNING
    else
        JNDI_PROVIDER_URL="$AMQ_PROTOCOL://$2:$3$AMQ_PROVIDER_OPTIONS"
    fi

	INPUT_Q=dynamicQueues/REQUEST
	OUTPUT_Q=dynamicQueues/REPLY
	VENDOR_SPECIFIC_SETTINGS="-pc $AMQ_PROVIDER_CLASS -ii $AMQ_CONTEXT_FACTORY -iu $JNDI_PROVIDER_URL -cf $AMQ_CONNECTION_FACTORY -oq $OUTPUT_Q -iq $INPUT_Q"
}

##############################################################################
# Calls perfharness.jar to show its command line options and all its help
##############################################################################
showHelp()
{
	echo_my "JMSPerf help:"
	java -cp $CLASSPATH $JAVA_OPTS JMSPerfHarness -hf 
}

##############################################################################
# Search for the results of the test run in the output log file
#
# Param
# 1 - File to be searched
# 2 - "Requestor" or "Responder"
# 3 - Server type (AMQ or WMQ)
# 4 - Test type (persistent or not)
# 5 - Message size
# 6 - File to write the results into
##############################################################################
searchForResults() {
	echo_my "Searching for results: $1 : $2 : $3 : $4 : $5 : $6 ..."
	STATUS=0
	COUNT=0
	MAX_WAIT_NO_MESSAGE=$[REQUESTOR_RUN_TIME + 60]
	calculateClientThreads $3 $4
	
	# Example of what we need to be searching for: 
	# totalIterations=6833,avgDuration=2.00,totalRate=3414.79
	SEARCH_PATTERN="totalRate"

	while [ $STATUS = 0 ]
	do
		# grep returns code 0 if string was found at least once
		set +e
		FOUND=$(grep "$SEARCH_PATTERN" $1)
		RC=$?
		set -e
		# 0 means found, 1 not found, 2 - file does not exist
		if [ $RC = 0 ]; then
			# finish this task as we have found the message
			STATUS=1
			MSG_RATE=$(echo $FOUND | sed -e 's/totalIterations=[0-9]*,avgDuration=[0-9]*.[0-9]*,totalRate=//')
			# Now need to write the result into the file
			echo_my "Message rate: '$MSG_RATE'"
			# Only print header line once at the top of the file
			if [ $HEADER_LINE_PRINTED = false ]; then
				echo -e "FinishTime \tRunSecs \tThreads \tQs \tCorr \tOpsMode \tVendor \tTestType \tMsgSize \tMsgRatePerSecond" >> $6
				HEADER_LINE_PRINTED=true
			fi
			echo -e "`date` \t$REQUESTOR_RUN_TIME \t$CLIENT_THREADS \t$MAX_Q_NUM \t$CORRELATION \t$2 \t$3 \t$4 \t$5 \t$MSG_RATE" >> $6
		else
			# since correct string is not found, need to wait a little more for server to start
			if [ $COUNT -gt $MAX_WAIT_NO_MESSAGE ]; then
				echo_my "We have waited long enough $MAX_WAIT_NO_MESSAGE - and there is no message, this means something went wrong with the test." $ECHO_ERROR
				exit 1
			else
				# Sleep every few sec
				sleep 5
				COUNT=$[COUNT + 5]
				echo_my "Waiting $COUNT sec (up to $MAX_WAIT_NO_MESSAGE sec) for test to complete and results to be shown in file '$1'..." $ECHO_INFO
			fi
		fi
	done
}	

##############################################################################
# Calls perfharness.jar after all the prior setup has been complete
# This needs requestor or provider to be setup prior to calling it
# Needs AMQ or WMQ client to be setup prior to calling it
#
# Params
# 1 - Server type: AMQ or WMQ
# 2 - Operation kind: Requestor or Responder
# 3 - QoS: Persistent or not
# 4 - Queue Manager name
# 5 - Port number
# 6 - Host name
# 7 - Client ID (to make sense of it in the output if starting many of these in parallel in one shell)
# 8 - Message size
##############################################################################
callPerfHarness() {
	echo_my "Starting IBM Performance Harness for JMS..."
	CLIENT_ID=$7
	MSG_SIZE=$8
	setupOperation$2
	setupServerType$1 $4 $6 $5 $2 $7
	setupQoS$3
	calculateClientThreads $1 $3
	
	COMMAND="-cp $CLASSPATH $JAVA_OPTS JMSPerfHarness -su -id $CLIENT_ID -tc $REQUESTOR $VENDOR_SPECIFIC_SETTINGS -db $MIN_Q_NUM -dx $MAX_Q_NUM -to $TIMEOUT -co $CORRELATION -mt $MSG_TYPE -mf $MESSAGE_PATH/$MSG_SIZE -wi $WAIT -rl $RUN_TIME -sw $WARM_UP_TIME -ss $STATRPT -nt $CLIENT_THREADS -pp $USE_PERSISTENT_MSGS -tx $TRANSACTIONS -sc BasicStats"

	echo_my "Command to be run='java $COMMAND'"
	java $COMMAND
}

##############################################################################
# Run many parallel clients for different queue managers. 
# This function overrides many default variables and is just one example of the test.
# It exists so that both responder and requestor are in synch on settings.
# Hardcoded server type etc. so that this can be called from requestor.sh and 
# responder.sh and options changed all in one place, instead of in two different files
#
# Param
# 1 - "Requestor" or "Responder"
# 2 - Server type (AMQ or WMQ)
# 3 - Test type (persistent or not)
# 4 - Message size
# 5 - repeat run
##############################################################################
runParallelClients() {
	echo_my "Starting to run multiple clients load test..."
	OPERATION=$1
	SERVER=$2
	TEST=$3
	MSG_SIZE=$4
	
	echo_my "Results of the test in progress can be found in directory $LOG_DIR"
	TEMP_RESULT=$LOG_DIR/$1.$2.$3.$4.$5.log.

	TOTAL_CLIENTS=0
	
	# Need to cleanup temp files before running new tests
	#rm -f $TEMP_RESULT* | true
	
	# Client ID shifts for requestor vs responder
	if [ $OPERATION = $REQUESTOR ]; then
		CLIENT_ID=1
	else
		CLIENT_ID=$CLIENT_ID_SHIFT;
	fi

	# Depending on the server, we need to call the test differently
	if [ $SERVER = $AMQ ]; then
		HOST=$AMQ_HOST
		for PORT in $LIST_AMQ_PORTS
		do
			callPerfHarness $SERVER $OPERATION $TEST blah $PORT $HOST $CLIENT_ID $MSG_SIZE | tee $TEMP_RESULT$CLIENT_ID &
			CLIENT_ID=$[CLIENT_ID + 1]
			TOTAL_CLIENTS=$[TOTAL_CLIENTS + 1]
		done
	else if [ $SERVER = $WMQ ]; then
		HOST=$WMQ_HOST
		PORT=142
		for i in $LIST_WMQ_MANAGERS
		do
			callPerfHarness $SERVER $OPERATION $TEST PERF$i $PORT$i $HOST $CLIENT_ID $MSG_SIZE | tee $TEMP_RESULT$CLIENT_ID &
			CLIENT_ID=$[CLIENT_ID + 1]
			TOTAL_CLIENTS=$[TOTAL_CLIENTS + 1]
		done
	else
		echo_my "ERROR: nothing to do - server type is not specified correctly: SERVER='$SERVER'"
	fi
	fi
	
	# Now need to figure out the resulting time - we shall wait until all results are in output files and then get em' from there
	if [ $OPERATION = $REQUESTOR ]; then
		for i in `seq 1 $TOTAL_CLIENTS`;
		do
			searchForResults $TEMP_RESULT$i $OPERATION $SERVER $TEST $MSG_SIZE $RESULTS_FILE
		done
	fi
}

##############################################################################
# Simply shows help for running this as a standalone script
##############################################################################
show_help()
{
	echo "Usage: ./run_perfharness.sh [<server_type> <client_type> <test_type> <q_mgr_name> <port_name> <host_name>]"
	echo "<Server_types>" $ECHO_NO_PREFIX
	for RUNTIME in $LIST_OF_SERVERS
	do
		echo "  -$RUNTIME"
	done
	echo "<Client_type>"
	for CLIENT in $LIST_OF_CLIENTS
	do
		echo "  -$CLIENT"
	done
	echo "<Test_type>"
	for TASK in $LIST_OF_TEST_TYPES
	do
		echo "  -$TASK"
	done
	echo "Example use: ./perfharness.sh $WMQ $REQUESTOR $PERSISTENT PERF0 1420 mqhost.com"
    echo
    exit 2
}

#############################################
# MAIN BODY starts here
#############################################

me=`basename $0`
if [ $me != "perfharness.sh" ]; then
	# do nothing - this means this script is simply sourced as part of another script
	# and functions are called directly
	echo_my "This script '$BASH_SOURCE' is included via 'source' into script '$me'" $ECHO_DEBUG
else
	echo_my "---------------------------------------------------------"
	echo_my "This script will call IBM Performance Harness for JMS"
	echo_my "Read more about this script here: http://WhyWebSphere.com"
	echo_my "---------------------------------------------------------"
	if [ $# -gt 5 ]; then
		echo_my "Number of arguments='$#' and their values are: SERVER_TYPE='$1' CLIENT_TYPE='$2' TEST_TYPE='$3' Q_MGR='$4' PORT='$5' HOST='$6'"
		perfHarnessSetup $1 $2 $3 $4 $5 $6
	else
		show_help
	fi
	echo_my "The '$BASH_SOURCE' script is done."
fi
