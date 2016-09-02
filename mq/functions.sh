#!/bin/bash
# VERSION:	1.22
# DATE:		Feb 5, 2015
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#			With help from the IBM Hursley Lab.
# DESCRIPTION:
# 	This script is to be used by other scripts.
#	Some decent tuning parameters for WMQ Queue Managers. Read more in the MQ docs: http://ibm.co/1jksAHC
#	Also see this article on tuning: http://www.ibm.com/developerworks/websphere/library/techarticles/0712_dunn/0712_dunn.html

# Tuning options for "qm.ini", channels, etc/
LOG_TYPE=CIRCULAR
LOG_TYPE_CRTMQM="-lc"
LOG_INTEGRITY=TripleWrite
MQIBindType=FASTPATH
# Set it to 100MB - when we have lots of memory
DefaultQBufferSize=104857600
DefaultPQBufferSize=104857600
MAX_MSG_SIZE=104857600
LOG_BUFFER_PAGES=4096
####################################################################
####################################################################
####################################################################
####################################################################
#LOG_PRIMARY_FILES=3
LOG_PRIMARY_FILES=40
####################################################################
####################################################################
####################################################################
####################################################################
# For performance reasons is is not recommended to use secondary log files as they are dynamically allocated (not pre-formatted)
LOG_SECONDARY_FILES=1
#LOG_FILE_PAGES=16384
LOG_FILE_PAGES=65535
MAX_HANDLES=50000
MAX_DEPTH=50000
FDMAX=1048576
MAX_CHANNELS=5000

source $PROJECT_DIR/mq/add_user.sh

ECHON=${ECHON-echo}
me=$(basename $0)

##############################################################################
# Convert a string to a regular expression that matches only the given string.
#
# Parameters
# 1 - The string to convert
##############################################################################
regexify() {
	# Won't work on HPUX
	echo $1 | sed -r 's/([][\.\-\+\$\^\\\?\*\{\}\(\)\:])/\\\1/g'
}

###############################################
# Delete a line containing a REGEX from a file,
# then append a new line.
#
# Parameters
# 1 - The REGEX to search for and delete
# 2 - The line to append
# 3 - The file to edit
###############################################
delAndAppend() {
	echo "Updating entry in $3: $2"
	awk '{if($0!~/^[[:space:]]*'$1'/) print $0}' $3 > $3.new
	mv $3.new $3
	echo "$2" >> $3
}

###################################################
# Copy the given file to a file with the same path,
# but a timestamp appended to the name.
#
# Parameters
# 1 - The name of the file to backup
###################################################
backupFile() {
	cp $1 $1.`date +%Y-%m-%d.%H%M`
}

#############################################
# updateSysctl
# Update values in the /etc/sysctl.conf file.
#
# Parameters
# 1 - The value to update
# 2 - The new value
#############################################
updateSysctl() {
	delAndAppend `regexify $1` "$1 = $2" /etc/sysctl.conf
}

#############################################
# UpdateSysctl
# Update values in the /etc/sysctl.conf file.
#
# Parameters
# 	none
#############################################
UpdateSysctl() {
	# First we need to make a backup of existing kernel settings before we change anything
	backupFile /etc/sysctl.conf

	# Now can set some new values
	echo "" >> /etc/sysctl.conf
	echo "# The following values were changed by $me [`date`]." >> /etc/sysctl.conf

	# The maximum number of file-handles that can be held concurrently
	updateSysctl fs.file-max $FDMAX
	# The maximum and minimum port numbers that can be allocated to outgoing connections
	updateSysctl net.ipv4.ip_local_port_range '1024 65535'
	# Maximum number of disjoint (non-contiguous), sections of memory a single process can hold (i.e. through calls to malloc).
	updateSysctl vm.max_map_count 1966080
	# The maximum PID value. When the PID counter exceeds this, it wraps back to zero.
	updateSysctl kernel.pid_max 655360
	# Tunes IPC semaphores. Values are:
	#  1 - The maximum number of semaphores per set
	#  2 - The system-wide maximum number of semaphores
	#  3 - The maximum number of operations that may be specified in a call to semop(2)
	#  4 - The system-wide maximum number of semaphore identifiers 
	updateSysctl kernel.sem '1000 1024000 500 8192'
	# The maximum size (in bytes) of an IPC message queue
	updateSysctl kernel.msgmnb  131072
	# The maximum size (in bytes) of a single message on an IPC message queue
	updateSysctl kernel.msgmax  131072
	# The maximum number of IPC message queues
	updateSysctl kernel.msgmni  2048
	# The maximum number of shared memory segments that can be created
	updateSysctl kernel.shmmni  8192
	# The maximum number of pages of shared memory
	updateSysctl kernel.shmall  536870912
	# The maximum size of a single shared memory segment
	updateSysctl kernel.shmmax  137438953472
	# TCP keep alive setting
	updateSysctl net.ipv4.tcp_keepalive_time 300

	# Some settings borrowed from WMQ 8.0 performance report, page 59
	updateSysctl kernel.sched_latency_ns 2000000
	updateSysctl kernel.sched_min_granularity_ns 1000000
	updateSysctl kernel.sched_wakeup_granularity_ns 400000
	updateSysctl net.core.somaxconn 163

	# Some settings borrowed from WMQ 7.1 performance report, page 66
#	updateSysctl net.ipv4.ip_forward 0
#	updateSysctl net.ipv4.conf.default.rp_filter 1
#	updateSysctl net.ipv4.conf.default.accept_source_route 0
#	updateSysctl kernel.sysrq 0
#	updateSysctl kernel.core_uses_pid 1
#	updateSysctl net.ipv4.tcp_syncookies 1
##	updateSysctl kernel.msgmnb 65536
##	updateSysctl kernel.msgmax 65536
#	updateSysctl net.ipv4.conf.all.accept_redirects 0
##	updateSysctl kernel.sem '500 512000 250 4096'
##	updateSysctl kernel.msgmni 1024
##	updateSysctl kernel.shmmni 4096
##	updateSysctl kernel.shmall 2097152
##	updateSysctl kernel.shmmax 268435456
#	updateSysctl fs.file-max 400000
#	updateSysctl kernel.pid_max 120000
#	updateSysctl net.ipv4.ip_local_port_range '8192 65535'
#	updateSysctl vm.max_map_count 1966080
	
	echo "" >> /etc/sysctl.conf

	# there is a bug in RHEL where bridge settings are set by default and they should not be, so we have to pass '-e' option here
	# read more: https://bugzilla.redhat.com/show_bug.cgi?id=639821
	sysctl -e -p
}

#############################################
# Add new 'mqm' user and update his ulimits and group membership
#############################################
AddMQMuser() {
	echo "------> This function configures Linux kernel so that we can later install WMQ rpms"

	# Add mqm group and ignore the error if the group already exists
	groupadd mqm | true

	# Add mqm user and ignore the error if the user already exists
	useradd mqm -g mqm | true

	# Update ulimits for mqm
	UpdateUserLimits mqm

	# Update ulimits for current user
	UpdateUserLimits $SUDO_USER

	# Add current user to the mqm group, so that the current user can call mq commands
	usermod --groups mqm $SUDO_USER

	echo "<------"
}

#############################################
# UpdateUserLimits
#	This function updates user limits for the given user $1
# Params
# 1 - username
#############################################
UpdateUserLimits() {
	echo "------> Configuring user limits for the user $1"

	backupFile /etc/security/limits.d/$1.conf | true
	cat <<-EOF > /etc/security/limits.d/$1.conf
		# Security limits for members of the mqm group
		@mqm soft nofile $FDMAX
		@mqm hard nofile $FDMAX
		@mqm soft nproc  $FDMAX
		@mqm hard nproc  $FDMAX
EOF

	echo "<------ new file [/etc/security/limits.d/$1.conf] created."
}

#############################################
# Create QM.ini file
#
# Parameters
# 1 - Queue Manager temporary file name
# 2 - Queue Manager log file path
# 3 - Queue Manager name
#############################################
CreateQueueManagerIniFile() {
	echo "------> This function creates queue manager $QM qm.ini file in local directory"
	rm -f $1
	cat << EOF > $1
#*******************************************************************#
#* Module Name: qm.ini                                             *#
#* Type       : WebSphere MQ queue manager configuration file      *#
#* Function   : Define the configuration of a single queue manager *#
#* 																   *#
#*              This file was generated by 'functions.sh' script   *#
#*              Refer to http://whywebsphere.com for details       *#
#*******************************************************************#
ExitPath:
   ExitsDefaultPath=/var/mqm/exits
   ExitsDefaultPath64=/var/mqm/exits64
Log:
   LogPrimaryFiles=$LOG_PRIMARY_FILES
   LogSecondaryFiles=$LOG_SECONDARY_FILES
   LogFilePages=$LOG_FILE_PAGES
   LogType=$LOG_TYPE
   LogBufferPages=$LOG_BUFFER_PAGES
   LogPath=$2/$3/
   LogWriteIntegrity=$LOG_INTEGRITY
Service:
   Name=AuthorizationService
   EntryPoints=14
ServiceComponent:
   Service=AuthorizationService
   Name=MQSeries.UNIX.auth.service
   Module=amqzfu
   ComponentDataSize=0
Channels:
   MQIBindType=$MQIBindType
   MaxActiveChannels=$MAX_CHANNELS
   MaxChannels=$MAX_CHANNELS
TuningParameters:
   DefaultPQBufferSize=$DefaultPQBufferSize
   DefaultQBufferSize=$DefaultQBufferSize
TCP:
   SndBuffSize=0
   RcvBuffSize=0
   RcvSndBuffSize=0
   RcvRcvBuffSize=0
   ClntSndBuffSize=0
   ClntRcvBuffSize=0
   SvrSndBuffSize=0
   SvrRcvBuffSize=0
EOF
   echo "<------ qm.ini is created"
}

#############################################
# Create QM
#
# Parameters
# 1 - Queue Manager name
# 2 - Queue Manager listener port
# 3 - Queue Manager data file path
# 4 - Queue Manager log file path
#############################################
CreateQueueManager() {
	echo "------> This function creates queue manager $1 and all queues"
	if [[ -z "${SUDO_USER+present}" ]]; then
		# No need to do sudo if this function was called without sudo command
		echo "FYI: No sudo user defined."
		MY_SUDO=""
	else
		echo "FYI: Sudo user is '$SUDO_USER'"
		MY_SUDO="sudo -u $SUDO_USER"
	fi

	echo "--- Stopping existing queue manager first: $1"
	# if this returns error we ignore this as QM may not even exist
	$MY_SUDO endmqm -i $1 | true

	echo "--- Deleting existing queue manager: $1"
	# if this returns error we ignore this as QM may not even exist
	$MY_SUDO dltmqm $1 | true
	
	# if this returns error we ignore this as QM may not even exist
	$MY_SUDO rmvmqinf $1 | true

	echo "--- Creating new queue manager: $1"
	CREATE_COMMAND="$MY_SUDO crtmqm -q -u SYSTEM.DEAD.LETTER.QUEUE -h $MAX_HANDLES $LOG_TYPE_CRTMQM -ld $4 -lf $LOG_FILE_PAGES -lp $LOG_PRIMARY_FILES -ls $LOG_SECONDARY_FILES -md $3 $1"

	echo $CREATE_COMMAND
	$CREATE_COMMAND

	echo "--- Reset default values for the queue manager: $1"
	# what if we do not do this?
	$MY_SUDO strmqm -c $1

	echo "--- Generating qm.ini file"
	INI_TMP=qm.ini.tmp
	CreateQueueManagerIniFile $INI_TMP $4 $1

	echo "--- Copy new configuration over the one that was created by defaults"
	backupFile $3/$1/qm.ini | true
	$MY_SUDO cp $INI_TMP $3/$1/qm.ini
	# remove needs to be done separately so that initial qm.ini permissions are preserved
	rm $INI_TMP

	echo "--- Starting queue manager: $1"
	$MY_SUDO strmqm $1

	echo "--- Configure queue manager: $1"
	$MY_SUDO runmqsc $1 <<-EOF
		define qlocal($REQUESTQ) maxdepth($MAX_DEPTH)
		define qlocal($REPLYQ) maxdepth($MAX_DEPTH)
		alter qmgr chlauth(disabled)
		alter qmgr activrec(disabled)
		alter qmgr routerec(disabled)
		alter qmgr chad(enabled)
		alter qmgr maxmsgl($MAX_MSG_SIZE)
		alter qlocal(system.default.local.queue) maxmsgl($MAX_MSG_SIZE)
		alter qmodel(system.default.model.queue) maxmsgl($MAX_MSG_SIZE)
		define listener(L1) trptype(tcp) port($2) control(qmgr)
		start listener(L1)
		alter channel(system.def.svrconn) chltype(svrconn) sharecnv(1)
		alter channel(system.def.svrconn) chltype(svrconn) maxmsgl($MAX_MSG_SIZE)
EOF
#		alter channel(SYSTEM.AUTO.SVRCONN) chltype(svrconn) sharecnv(1)
#		alter channel(system.def.receiver) chltype(rcvr) sharecnv(1) mcatype('THREAD')
# 		define channel(system.admin.svrconn) chltype(svrconn) mcauser('mqm') replace
#		alter channel(system.def.svrconn) chltype(svrconn) mcauser($PERFORMANCE_USER) maxmsgl($MAX_MSG_SIZE)

	echo "--- Restart queue manager: $1"
	$MY_SUDO endmqm -i $1
	$MY_SUDO strmqm $1

	echo "--- Create queues in QM: $1"
	# read more about security settings here: http://www-01.ibm.com/support/docview.wss?uid=swg21577137
	# and here: http://stackoverflow.com/questions/8886627/websphere-mq-7-1-help-need-access-or-security/8886813#8886813
	$MY_SUDO runmqsc $1 < $Q_DEFINITION_FILE

	echo "<------ DONE with SUCCESS - creation of queue manager went well: $1"
}

#############################################
# RemoveeQueueManager
#
# Parameters
# 1 - Queue Manager name
#############################################
RemoveQueueManager() {
	echo "------> This function removes queue manager $1 and all queues"
	if [[ -z "${SUDO_USER+present}" ]]; then
		# No need to do sudo if this function was called without sudo command
		echo "FYI: No sudo user defined."
		MY_SUDO=""
	else
		echo "FYI: Sudo user is '$SUDO_USER'"
		MY_SUDO="sudo -u $SUDO_USER"
	fi

	echo "--- Stopping existing queue manager first: $1"
	# if this returns error we ignore this as QM may not even exist
	$MY_SUDO endmqm -i $1 | true

	echo "--- Deleting existing queue manager: $1"
	$MY_SUDO dltmqm $1 | true

	echo "<------ DONE with SUCCESS - removal of queue manager went well: $1"
}

#############################################
# CheckExistingWMQinstall
# This function tests if there is existing WMQ install in the $1
#
# Parameters
# 1 - path to the presumed WMQ install
#############################################
CheckExistingWMQinstall() {
	# First we check for existing WMQ directory
	if [ -d "$WMQ_INSTALL_DIR" ]; then
		echo "ERROR: There is already an '$WMQ_INSTALL_DIR' directory on your file system. If you want to install new copy of WMQ you have these choices:"
		echo "       (1) Rename that directory or (2) Edit *setenv.sh* file to point variable *WMQ_INSTALL_DIR* to a different location."
		echo ""
		exit 1
	fi
	
	# Second we check if WMQ rpms are already on the system.
	# TODO - we could allow to install multiple WMQ rpms on the system, but that would be future item. 
	# For now just abort if we have any existing WMQ rpms
	# grep returns code 0 if string was found at least once
		
	echo "Checking for existing WMQ rpms on this machine..."
	echo ""
	
	# 0 means found, 1 not found, 2 - file does not exist
	if rpm -qa | grep MQSeries 
	then
		echo ""
		echo "ERROR: There is already an WMQ install on this system."
		echo "       At present time this script does not handle multiple installations of WMQ on the same host."
		echo "       However you can easily add this function yourself. Exiting now."
		echo ""
		exit 1
	else
		echo "No existing installation of WMQ found on the system. Proceeding with the installation..."
	fi

	# TODO - may want to do some more check, other than simply checking for existing directory
}

#############################################
# InstallWMQ
#############################################
InstallWMQ() {
	echo "------> This function installs WMQ "
	mkdir $DOWNLOAD_PATH/wmq_install_unzipped | true
	cd $DOWNLOAD_PATH/wmq_install_unzipped
	tar xvf $DOWNLOAD_PATH/$WMQ_ARCHIVE
	
	# Accept IBM license
	./mqlicense.sh -accept

	# Now we can install WMQ	
	sudo rpm --prefix $WMQ_INSTALL_DIR -ivh MQSeriesRuntime-*.rpm MQSeriesServer-*.rpm MQSeriesClient-*.rpm MQSeriesSDK-*.rpm  MQSeriesMan-*.rpm MQSeriesSamples-*.rpm MQSeriesJRE-*.rpm MQSeriesExplorer-*.rpm MQSeriesJava-*.rpm
			   
	# Define this as a primary installation
	$WMQ_INSTALL_DIR/bin/setmqinst -i -p $WMQ_INSTALL_DIR

	# Show the version of WMQ that we just installed
	$WMQ_INSTALL_DIR/bin/dspmqver

	# Finally need to run check of prerequisites and see if any of the checks fail (Warnings exit=1, Errors exit=2)
	#su mqm -c "$WMQ_INSTALL_DIR/bin/mqconfig"
	su $SUDO_USER -c "$WMQ_INSTALL_DIR/bin/mqconfig"

	echo "<------ DONE with SUCCESS - installation of WMQ is complete at the following path: $WMQ_INSTALL_DIR"
}
