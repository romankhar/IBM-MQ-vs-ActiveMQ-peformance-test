#!/bin/bash
# March 7, 2014

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

# Depending from which directory this script is run it will call different 'setenv.sh" script - amq or mq version of it
source /home/roman/mom_performance/client/setenv.sh
source /home/roman/mom_performance/utils.sh

#######################################################################################################
# This function will copy entire project to a remote host
#
# Params
# 1 - hostname
#######################################################################################################
copyToRemoteHost() {
	local FOLDER_PATH=$BASE_DIR/..
	echo_my "Starting copying all files in this project '$FOLDER_PATH' to user '$REMOTE_USER' on host '$1'..." $ECHO_INFO
	scp -i ~/.ssh/id_rsa -r $FOLDER_PATH/* $REMOTE_USER@$1:$FOLDER_PATH
}

copyToRemoteHost $AMQ_HOST
copyToRemoteHost $WMQ_HOST

