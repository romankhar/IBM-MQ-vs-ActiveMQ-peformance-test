#!/bin/bash

#
# DESCRIPTION:	This script unpacks changes OS kernel settings
#
# RETURNED VALUES:
#   0  - Configuration completed successfully
#   1  - Something went wrong
#
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

##################################################
# Check that the current shell is running as sudo root, and exit if not.
##################################################
if [ $EUID != "0" -o -z "$SUDO_USER" ] ; then
	echo "" >&2
	echo "ERROR: This script must be run from non-root account with a sudo root command." >&2
	echo "       To learn how to add your user to the sudoers file, visit http://red.ht/1dRpB5C" >&2
	echo "" >&2
	exit 1
fi

if [ $SUDO_USER = "root" ] ; then
	echo "" >&2
	echo "ERROR: The sudo user must be a non-root." >&2
	echo "       Log in as a non-root user and run this script again using the sudo command." >&2
	echo "" >&2
	exit 1
fi

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

source hosts.sh
source $PROJECT_DIR/mq/functions.sh

echo "------------------------------------------------------------------------------"
echo " This script will tune OS sysctl - it is recommended for AMQ host and MQ host"
echo " (although for MQ host it will be called as part of my install script)"
echo "------------------------------------------------------------------------------"

# Define Linux kernel parameters
UpdateSysctl

# Add mqm user and set ulimits
AddMQMuser
	
echo "-------------------------------------------------------------------------------"
echo " SUCCESS: OS tuning complete."
echo "-------------------------------------------------------------------------------"