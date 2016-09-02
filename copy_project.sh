#!/bin/bash

#
# DESCRIPTION: 	This script makes a copy of the project folder into remote machines so it can be executed remotely
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

set -o nounset
set -o errexit

source /home/roman/mom_performance/client/setenv_client.sh
source /home/roman/mom_performance/utils.sh

##############################################################################
# Create proper directories on remote hosts
# 1 - Host name
##############################################################################
prepareDirectories()
{
	echo_my "prepareDirectories() on host '$1'..." $ECHO_DEBUG
	# these folders may already exist, in which case we ignore the error
	ssh $1 "mkdir $PROJECT_DIR" | true
	ssh $1 "mkdir $PROJECT_DIR/client" | true
}

#######################################################################################################
# This function will copy entire project to a remote host
#
# Params
# 1 - hostname
#######################################################################################################
copyToRemoteHost() {
	local FOLDER_PATH=$BASE_DIR/..
	echo_my "Starting copying all files in this project '$FOLDER_PATH' to user '$REMOTE_USER' on host '$1'..." $ECHO_INFO
	# before running this command - please create a directory /home/roman/mom_project/client (or similar) on remote host
	scp -i ~/.ssh/id_rsa -r $FOLDER_PATH/* $REMOTE_USER@$1:$FOLDER_PATH
}

#######################################################################################################
# This function moves all files of pattern $1 from $SOURCE_DIR to $TMP_DIR
#######################################################################################################
move_it(){
	find $SOURCE_DIR -name "$1" -exec mv {} $TMP_DIR \;
}

#######################################################################################################
# This function will clean directories fron junk (logs, core dumps, etc.)
#######################################################################################################
cleanup_folders() {
	SOURCE_DIR=$PROJECT_DIR
	mkdir $HOME/backup | true
	mkdir $HOME/backup/junk | true
	TMP_DIR=$HOME/backup/junk/`date +%Y-%m-%d.%H%M%S`
	echo_my "Cleaning project folders fron junk - moving all the junk to $TMP_DIR..." $ECHO_INFO
	mkdir $TMP_DIR
	move_it "*.trc"
	move_it "javacore*"
	move_it "heapdump*"
	move_it "*.dmp"
	move_it "mqjms*"
	move_it "FFDC*"
	move_it "*sh~"
	move_it "*.log"
	move_it "*.log.*"
	move_it "*.swp"
}

#######################################################################################################
# MAIN
#######################################################################################################
prepareDirectories $AMQ_HOST
prepareDirectories $WMQ_HOST
cleanup_folders
copyToRemoteHost $AMQ_HOST
copyToRemoteHost $WMQ_HOST