#!/bin/bash

#
# These are settings for the WebSphere MQ host (must be in MQ subdirectory of the project)
#

export REMOTE_HOST=mqhost
export REMOTE_USER=roman
export BASE_DIR=/home/$REMOTE_USER/mom_performance/mq
export CLIENT_HOST_BASE_DIR=$HOME/mom_performance/mq

export WMQ_INSTALL_DIR=/opt/mqm
export LD_LIBRARY_PATH=$WMQ_INSTALL_DIR/java/lib64
export JAVA_HOME=$WMQ_INSTALL_DIR/java/jre64/jre
export PATH=$PATH:$WMQ_INSTALL_DIR/bin:$JAVA_HOME/bin

# These below are only used for the initial installation, but not for ongoing tasks
export QM=QM1
export PORT=1420
export REQUESTQ=REQUEST_Q
export REPLYQ=REPLY_Q
export MQ_CONNECT_TYPE=FASTPATH
