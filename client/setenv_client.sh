#!/bin/bash

#
# DESCRIPTION:	This script sets up common variables for being used in performance test.
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

# ---------------------------------------------------------------------------------------
# Generic settings for the project overall
# ---------------------------------------------------------------------------------------
source /home/roman/mom_performance/hosts.sh

export LD_LIBRARY_PATH=$WMQ_INSTALL_DIR/java/lib64
# Please note that this needs to be on the clienthost as well as on amqhost and mqhost - this is used by local and ssh started clients (it is ok if AMQ is started by another JVM)
export JAVA_HOME=$WMQ_INSTALL_DIR/java/jre64/jre
PATH=$PATH:$JAVA_HOME/bin
BASE_DIR=$PROJECT_DIR/client
RESULTS_FILE=$BASE_DIR/run.log
RESPONDER_LOG=responder.log
LOG_DIR=$BASE_DIR/logs
HEADER_LINE_PRINTED=false
CLASSPATH=$BASE_DIR/perfharness12.jar

# ---------------------------------------------------------------------------------------
# IBM Performance Harness for JMS (load generation client) specific settings
# ---------------------------------------------------------------------------------------
# How many times to repeat the test for each set of configuration settings (to use the average result of several runs)
REPEATS=3

# How many concurrent client threads to start within a single JMSPerf.jar call
# The value of CLIENT_THREADS will be calculated later by dividing NP_CLIENT_THREADS or CLIENT_THREADS by the number of servers, 
# thus calculating number of threads for each server connection
# for NON-PERSISTENT test
NP_CLIENT_THREADS=100
# for PERSISTENT test
P_CLIENT_THREADS=100

# how many more responders to start relative to the number of requestors (for the equal number of requestors and responders set this to 1)
RESPONDER_MULTIPLIER=1.2

# Possible message sizes
MSG_20=00_20.xml
MSG_256=01_256.xml
MSG_1024=02_1024.xml
MSG_10K=03_10K.xml
MSG_100K=04_100K.xml
MSG_1M=05_1M.xml
MSG_10M=06_10M.xml
#LIST_OF_MSG_SIZES="$MSG_20 $MSG_256 $MSG_1024 $MSG_10K $MSG_100K $MSG_1M $MSG_10M"
LIST_OF_MSG_SIZES="$MSG_20 $MSG_256 $MSG_1024 $MSG_10K $MSG_100K $MSG_1M"
MESSAGE_PATH=$BASE_DIR/messages

# Types of tests to be run
PERSISTENT=Persistent
NON_PERSISTENT=NonPersistent
#LIST_OF_TEST_TYPES="$NON_PERSISTENT $PERSISTENT"
LIST_OF_TEST_TYPES="$PERSISTENT"

# I want the total test time for requestor to be shorter than responder - the reason is that we are measuring performance based on requestor and hence responder needs to be already 
# running before we even start requestor to avoid zero message rate - in fact, we could even leave responder running forever 
# 24 hours = 86400
REQUESTOR_RUN_TIME=600

# These variables below can be extended to support other providers, but then you would have to add new functions to the script
AMQ=AMQ
WMQ=WMQ
LIST_OF_SERVERS="$WMQ $AMQ"
#LIST_OF_SERVERS="$AMQ"

# Test warmup time - this period wont be included in summary stats
WARM_UP_TIME=60

# run responder for one week in background: 60 sec * 60 min * 24 hrs * 7 days
RESPONDER_RUN_TIME=604800

# Number to be appended to the end of the queue name (i.e. REQUEST1, REQUEST2 or REPLY1, REPLY2, etc. up to the max)
# Please note that total number of queues is a multiple of MAX_Q_NUM and the number of servers (brokers)
# For example, if we have 4 servers, then total number of queues is 4*MAX_Q_NUM*2 (where 2 is for request and reply queue)
MIN_Q_NUM=1
MAX_Q_NUM=5
#MAX_Q_NUM=20

# Stat reporting frequency in seconds
STAT_REPORT_SEC=5

# how do we start the JVM with PerfHarness
JAVA_OPTS="-Xms4g -Xmx4g"

# Message wait timeout for perfharness
TIMEOUT=40000

# Message type (text,bytes,stream,map,object,empty). (default: text)
MSG_TYPE=text

# WorkerThread start interval (ms). This controls the pause between starting multiple threads
WAIT=0

# If need to use correlation IDs, need to pass the option ('false' default)
CORRELATION=false

# Requestor initiates message and waits for reply
REQUESTOR=Requestor
# Responder gets the message from the input Q and puts that same message to the reply Q without touching the content
RESPONDER=Responder
# This list is only used to display help for command line usage
LIST_OF_CLIENTS="$REQUESTOR $RESPONDER"

# This number below will be used as a difference between Requestor and Responder client IDs. 
CLIENT_ID_SHIFT=1000

AMQ_INPUT_Q=dynamicQueues/REQUEST
AMQ_OUTPUT_Q=dynamicQueues/REPLY

MQ_INPUT_Q=REQUEST
MQ_OUTPUT_Q=REPLY

# ---------------------------------------------------------------------------------------
# IBM WebSphere MQ specific settings
# ---------------------------------------------------------------------------------------

WMQ_ACKNOWLEDGEMENT_MAX_MSGS=10
	
# For more WMQ settings see ../mq/functions.sh in the *CreateQueueManagerIniFile* function

# ---------------------------------------------------------------------------------------
# Apache ActiveMQ specific settings
# ---------------------------------------------------------------------------------------

AMQ_PROVIDER_CLASS="JNDI"
AMQ_CONTEXT_FACTORY="org.apache.activemq.jndi.ActiveMQInitialContextFactory"
AMQ_CONNECTION_FACTORY="ConnectionFactory"

# Default values for many of the settings below - hence no need to add to the options list
# I tested all of these in various permutations and they made no difference if I change from default

# http://activemq.apache.org/configuring-wire-formats.html
# Non-production configuration may be OK with using the 'vm:' bindings for AMQ, in which case set it to 'true'
AMQ_USE_VM_PROTOCOL="false"
AMQ_PROTOCOL="tcp"
# despite all claims, the use of NIO actually decreased performance
#AMQ_PROTOCOL="nio"
# http://activemq.apache.org/what-is-the-prefetch-limit-for.html
#AMQ_jms_prefetchPolicy_all="jms.prefetchPolicy.all=1000"
# set it to the same value as for WMQ - for XA transactions this may need to be 0
AMQ_jms_prefetchPolicy_all="jms.prefetchPolicy.all=$WMQ_ACKNOWLEDGEMENT_MAX_MSGS"
AMQ_wireFormat_cacheEnabled="wireFormat.cacheEnabled=true"
AMQ_wireFormat_tightEncodingEnabled="wireFormat.tightEncodingEnabled=true"
# http://activemq.apache.org/tcp-transport-reference.html
# socketBufferSize=131072 (default = 64*1024)
# ioBufferSize=16384 (default 8*1024)
AMQ_socketBufferSize="socketBufferSize=131072"
AMQ_ioBufferSize="ioBufferSize=16384"
# http://activemq.apache.org/connection-configuration-uri.html	
AMQ_jms_dispatchAsync="jms.dispatchAsync=false"
# jms.useAsyncSend=false	(can be true if message loss is ok)
AMQ_jms_useAsyncSend="jms.useAsyncSend=false"
AMQ_jms_optimizeAkcnowledge="jms.optimizeAkcnowledge=false"
# jms.alwaysSessionAsync=true   (for non-persistent)
AMQ_jms_alwaysSessionAsync="jms.alwaysSessionAsync=true"

# This variable below pulls all settings together and will be used to connect to AMQ
AMQ_PROVIDER_OPTIONS="?$AMQ_jms_prefetchPolicy_all"