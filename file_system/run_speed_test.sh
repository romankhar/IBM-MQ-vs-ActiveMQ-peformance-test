#!/bin/bash

#
# DESCRIPTION:
# 	Shared reusable generic functions
# AUTHOR:   	
#	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

set -o nounset
set -o errexit

###############################################
# Starts measurements of time
###############################################
start_timer()
{
	echo "start_timer()..."
	START_TIME=`date +%s`
}

###############################################
# Stop timer and write data into the log file
###############################################
stop_timer()
{
	END_TIME=`date +%s`
	MEASURED_TIME=`expr $END_TIME - $START_TIME`
	echo "... stop_timer() - measured time = $MEASURED_TIME"
	SPEED=`expr $SIZE / $MEASURED_TIME / 1000000`
	echo "=========> File copy speed = $SPEED MB/sec"
}

###############################################
# Copy file
###############################################
copy_one_big_file()
{
	SOURCE=/home/roman/Downloads/WS_MQ_LINUX_ON_X86_64_V8.0_IMG.tar.gz
	DEST=/home/roman/Downloads/ttt
	SIZE=558767000
	cp -f $SOURCE $DEST
	echo "Info about $DEST file - AFTER"
	ls -l $DEST
}

###############################################
# Copy directory
###############################################
copy_big_directory()
{
	SOURCE=/home/roman/Downloads/wmq_install_unzipped
	DEST=/home/roman/Downloads/tttt
	SIZE=2322380000
	cp -rf $SOURCE $DEST
	echo "Info about $DEST file - AFTER"
	ls -l $DEST
}

###############################################
# Copy directory to remote host
###############################################
copy_big_directory_to_remote_host()
{
	SOURCE=/home/roman/Downloads/wmq_install_unzipped
	DEST=roman@mqhost:/home/roman/Downloads/tttt
	SIZE=2322380000
	scp -r $SOURCE $DEST
}

###############################################
# Copy big file to remote host
###############################################
copy_big_file_to_remote_host()
{
	SOURCE=/home/roman/Downloads/tttt/WS_MQ_LINUX_ON_X86_64_V8.0_IMG.tar.gz
	DEST=roman@mqhost:/home/roman/Downloads/big_file
	SIZE=558767000
	scp $SOURCE $DEST
}

###############################################
# MAIN
###############################################

# basic info about the HDD
sudo hdparm -I /dev/sda

# do some measurements of performance
start_timer
copy_one_big_file
stop_timer

start_timer
copy_big_directory
stop_timer

start_timer
copy_big_file_to_remote_host
stop_timer

start_timer
copy_big_directory_to_remote_host
stop_timer

sudo hdparm -t /dev/sda3
sudo hdparm -t /dev/sdb1

sudo hdparm -t --direct /dev/sda