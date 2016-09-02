#!/bin/bash

#
# DESCRIPTION:	Starts all queue managers
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

set -o nounset
set -o errexit

source /home/roman/mom_performance/hosts.sh
source $PROJECT_DIR/amq/setenv_amq.sh
source $PROJECT_DIR/utils.sh
source $PROJECT_DIR/amq/list_servers.sh

COUNTER=1

for i in $LIST_AMQ_MANAGERS 
do
	echo_my "------------> Starting AMQ server '$i'..."
	JETTY_PORT=${JETTY_PORT_BASE}${COUNTER}
	echo_my "JETTY_PORT='$JETTY_PORT'"
	AMQ_PORT=${PORT_PREFIX}${COUNTER}${PORT_POSTFIX}
	echo_my "AMQ_PORT='$AMQ_PORT'"
	AMQP_PORT=567${COUNTER}
	# When using new version of ActiveMQ do not forget to update the file /home/roman/apache-activemq-5.11.0/bin/env - by adding ACTIVEMQ_OPTS
	export ACTIVEMQ_OPTS="-Djetty.port=$JETTY_PORT -Damq.port=$AMQ_PORT -Damqp.port=$AMQP_PORT -Dactivemq.brokername=$i"
	echo_my "ACTIVEMQ_OPTS=$ACTIVEMQ_OPTS"
	eval INSTANCE_PATH=\$INSTANCE${COUNTER}_PATH
	echo_my "INSTANCE_PATH=$INSTANCE_PATH" $ECHO_DEBUG
	$INSTANCE_PATH/bin/$i start
	COUNTER=$[COUNTER + 1]
	echo_my "<---------- AMQ Server '$i' has been started."
done