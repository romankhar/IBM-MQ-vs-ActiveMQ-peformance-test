#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# These are settings for the WebSphere MQ host (must be in MQ subdirectory of the project)
#

export REMOTE_HOST=mqhost
export REMOTE_USER=roman
export BASE_DIR=/home/$REMOTE_USER/mom_performance/mq
export CLIENT_HOST_BASE_DIR=$HOME/mom_performance/mq
export Q_DEFINITION_FILE=queue_definitions.mqsc
BASE_LOG_DIR=/SSD1/MQ_LOGS
BASE_DATA_DIR=/SSD1/MQ_DATA

export WMQ_INSTALL_DIR=/opt/mqm
export LD_LIBRARY_PATH=$WMQ_INSTALL_DIR/java/lib64
export JAVA_HOME=$WMQ_INSTALL_DIR/java/jre64/jre
# "utils" is for utils, such as "q" and possibly others
export PATH=$PATH:$WMQ_INSTALL_DIR/bin:$JAVA_HOME/bin:/home/$REMOTE_USER/utils


# These below are only used for the initial installation, but not for ongoing tasks
export QM=QM1
export PORT=1420
export REQUESTQ=REQUEST_Q
export REPLYQ=REPLY_Q
export MQ_CONNECT_TYPE=FASTPATH
