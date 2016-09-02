#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script adds new user to the OS - or simply provides environment variable setting for other scripts
#
# RETURNED VALUES:
#   	0  - User add operation completed successfully
#   	1  - Something went wrong


# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

source /home/roman/mom_performance/hosts.sh
source $PROJECT_DIR/utils.sh
	
PERFORMANCE_USER=mqperf
PERFORMANCE_USER_PW=password
PERFORMANCE_USER_GRP=mqm

##############################################################################
# This function adds new user to the OS
#
# Parameters
# 1 - user name
# 2 - password
# 3 - user group
##############################################################################
add_user() {
	echo "Adding new user: user='$1'"
	# if user already exists - ignore the error (note that -M means no home directory will be created)
	sudo useradd -M -g $3 $1

	echo "Assign password for the user..."
	echo $2 | sudo passwd --stdin $1
}

#############################################
# MAIN BODY starts here
#############################################

# we only add new user if this script is called via command line
# otherwise this script can be used as a env setting script, but no action will be taken to add the user (such as from the client script)

me=`basename $0`
if [ $me != "add_user.sh" ]; then
	# do nothing - this means this script is simply sourced as part of another script
	# and functions are called directly
	echo_my "This script '$BASH_SOURCE' is included via 'source' into script '$me'" $ECHO_DEBUG
else
	echo_my "---------------------------------------------------------"
	echo_my "This script adds new OS user"
	echo_my "---------------------------------------------------------"
	
	add_user $PERFORMANCE_USER $PERFORMANCE_USER_PW $PERFORMANCE_USER_GRP
	
	echo_my "The '$BASH_SOURCE' script is done."
fi
