#!/bin/bash
# NAME:		setenv
# VERSION:	1.24
# DATE:		March 31, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
# DESCRIPTION:
# 	This script sets up common variables for being used in performance test.
#   More details here: http://whywebsphere.com/2014/03/13/websphere-mq-and-apache-activemq-performance-comparison-part-1/

#   http://WhyWebSphere.com

# ---------------------------------------------------------------------------------------
# Generic settings for the project overall
# ---------------------------------------------------------------------------------------

	# DNS names of hosts that run the server side of the software - i.e. 'hostname.domain.com'
	AMQ_HOST=amqhost
	WMQ_HOST=mqhost
	JAVA_HOME=/home/roman/jdk1.7.0_45
	WMQ_INSTALL_DIR=/opt/mqm
	AMQ_INSTALL_DIR=/home/roman/apache-activemq-5.9.0
	export LD_LIBRARY_PATH=$WMQ_INSTALL_DIR/java/lib64
	PATH=$PATH:$JAVA_HOME/bin
	REMOTE_USER=roman
	BASE_DIR=/home/roman/mom_performance/client
	RESULTS_FILE=$BASE_DIR/run_all.log
	RESPONDER_LOG=responder.log
	LOG_DIR=$BASE_DIR/logs
	HEADER_LINE_PRINTED=false
	CLASSPATH=$BASE_DIR/perfharness12.jar

# ---------------------------------------------------------------------------------------
# IBM Performance Harness for JMS (load generation client) specific settings
# ---------------------------------------------------------------------------------------

	# I want the total test time for requestor to be a little shorter than responder
	# the reason is that we are measuring performance based on requestor and hence responder needs to be already 
	# running before we even start requestor to avoid zero message rate
	# in fact, we could even leave responder running forever as long as it is using the same persistence and transactionality as the requester
	REQUESTOR_RUN_TIME=1200
	#REQUESTOR_RUN_TIME=180

	# run responder for one week in background: 60 sec * 60 min * 24 hrs * 7 days
	RESPONDER_RUN_TIME=604800

	# Test warmup time - this period wont be included in summary stats
	WARM_UP_TIME=60
	#WARM_UP_TIME=60

	# How many concurrent client threads to start within a single JMSPerf.jar call
	# The value of CLIENT_THREADS will be calculated later by dividing NP_CLIENT_THREADS or CLIENT_THREADS by the number of servers, 
	# thus calculating number of threads for each server connection
	# How many total concurrent client threads to start for NON-PERSISTENT test
	NP_CLIENT_THREADS=36
	#NP_CLIENT_THREADS=36
	# How many total concurrent client threads to start for PERSISTENT test
	P_CLIENT_THREADS=80
	#P_CLIENT_THREADS=60

	# Number to be appended to the end of the queue name (i.e. REQUEST1, REQUEST2 or REPLY1, REPLY2, etc. up to the max)
	# Please note that total number of queues is a multiple of MAX_Q_NUM and the number of servers (brokers)
	# For example, if we have 4 servers, then total number of queues is 4*MAX_Q_NUM*2 (where 2 is for request and reply queue)
	MIN_Q_NUM=1
	MAX_Q_NUM=5
	#MAX_Q_NUM=20

	# Possible message sizes
	MSG_256=01_256.xml
	MSG_1024=02_1024.xml
	MSG_10K=03_10K.xml
	MSG_100K=04_100K.xml
	MSG_1M=05_1M.xml
	LIST_OF_MSG_SIZES="$MSG_256 $MSG_1024 $MSG_10K $MSG_100K $MSG_1M"
	#LIST_OF_MSG_SIZES="$MSG_256"
	MESSAGE_PATH=$BASE_DIR/messages

	# Types of tests to be run
	PERSISTENT=Persistent
	NON_PERSISTENT=NonPersistent
	LIST_OF_TEST_TYPES="$NON_PERSISTENT $PERSISTENT"
	#LIST_OF_TEST_TYPES="$PERSISTENT"

	# Stat reporting frequency in seconds
	STATRPT=5

	# how do we start the JVM with PerfHarness
	JAVA_OPTS="-Xms1024M -Xmx1024M -Xmn800M"

	# Message wait timeout for perfharness
	TIMEOUT=40000

	# Message type (text,bytes,stream,map,object,empty). (default: text)
	MSG_TYPE=text

	# WorkerThread start interval (ms). This controls the pause between starting multiple threads
	WAIT=0

	# If need to use correlation IDs, need to pass the option
	CORRELATION=false

	# These variables below can be extended to support other providers, but then you would have to add new functions to the script
	AMQ=AMQ
	WMQ=WMQ
	LIST_OF_SERVERS="$WMQ $AMQ"

	# Requestor initiates message and waits for reply
	REQUESTOR=Requestor
	# Responder gets the message from the input Q and puts that same message to the reply Q without touching the content
	RESPONDER=Responder
	LIST_OF_CLIENTS="$REQUESTOR $RESPONDER"

	# This number below will be used asa difference between Requestor and Responder client IDs. 
	CLIENT_ID_SHIFT=100

# ---------------------------------------------------------------------------------------
# IBM WebSphere MQ specific settings
# ---------------------------------------------------------------------------------------

	WMQ_ACKNOWLEDGEMENT_MAX_MSGS=2000
	
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
	# http://activemq.apache.org/what-is-the-prefetch-limit-for.html
	AMQ_jms_prefetchPolicy_all="jms.prefetchPolicy.all=2000"
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
