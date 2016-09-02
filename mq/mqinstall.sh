#!/bin/bash

# VERSION:	1.2
# DATE:		January 14, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#
# DESCRIPTION:
# 	This script unpacks pre-existing downloaded version of WebSphereMQ on RHEL OS,
# 	modifies OS kernel settings, installs WMQ and creates one Queue Manager and test Queues
#
#   http://WhyWebSphere.com
#
# CAVEATS/WARNINGS:
# 	This script assumes that you already have downloaded tar of the WMQ.
# 	You can read more about the use of this script in this blog post: http://whywebsphere.com
#
# RETURNED VALUES:
#   0  - Configuration completed successfully
#   1  - Something went wrong

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

source setenv_mq.sh

# For best performance your queue file and your log file should point to two separate physical disks
QM_DATA_PATH=/var/mqm/${QM}_DATA
QM_LOG_PATH=/var/mqm/${QM}_LOG

# Feel free to change these as you see fit
DOWNLOAD_PATH=/home/$SUDO_USER/Downloads
WMQ_ARCHIVE=WS_MQ_LINUX_ON_X86_64_V8.0_IMG.tar.gz

source functions.sh

echo ""
echo "------------------------------------------------------------------------------"
echo " This script will install WebSphere MQ on your Linux OS"
echo " Read more about this script here: http://WhyWebSphere.com"
echo " Today's date: `date`"
echo " Here are the default values used in the script (feel free to change these):"
echo "   Insalling user:            '$SUDO_USER'"
echo "   WebSphere MQ Install Path: '$WMQ_INSTALL_DIR'"
echo "   Queue Manager Name:        '$QM'"
echo "   Queue Mgr Listener Port:   '$PORT'"
echo "   Queue Mgr Data Path:       '$QM_DATA_PATH'"
echo "   Queue Mgr Log Path:        '$QM_LOG_PATH'"
echo "   Test Queue #1:             '$REQUESTQ'"
echo "   Test Queue #2:             '$REPLYQ'"
echo "   WMQ installation image:    '$DOWNLOAD_PATH/$WMQ_ARCHIVE'"
echo "------------------------------------------------------------------------------"
echo ""

# Make sure there is not already existing WMQ install in the install directory
CheckExistingWMQinstall

# Define Linux kernel parameters before installing WMQ
UpdateSysctl

# Add mqm user and set ulimits
AddMQMuser
	
# Install WMQ
InstallWMQ

# Define first instance of queue manager (repeat these lines if you need multiple QMs)
CreateQueueManager $QM $PORT $QM_DATA_PATH $QM_LOG_PATH

# Start WMQ Explorer to manage the installation
$WMQ_INSTALL_DIR/bin/strmqcfg &

echo "-------------------------------------------------------------------------------"
echo " SUCCESS: WMQ installation, setup and test are complete."
echo " To test your message queues you may want to run this script: ./mqtest.sh"
echo "-------------------------------------------------------------------------------"
