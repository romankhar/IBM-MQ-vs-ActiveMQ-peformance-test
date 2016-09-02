#!/bin/bash

# NAME:		utils.sh
# VERSION:	1.1
# DATE:		March 21, 2014
# AUTHOR:   Roman Kharkovski (http://whywebsphere.com/resources-links)
# DESCRIPTION:
# 	Shared reusable generic functions
#   http://WhyWebSphere.com

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

ECHO_NONE=0
ECHO_NO_PREFIX=1
ECHO_ERROR=1
ECHO_WARNING=2
ECHO_INFO=3
ECHO_DEBUG=4

ECHO_LEVEL=$ECHO_DEBUG

##############################################################################
# Replace standard ECHO function with custom output
#
# Params
# 1 - Text to show
# 2 - Type of output (optional) - ERROR, WARNING, INFO
##############################################################################
echo_my()
{
#	PREFIX="(`hostname`:$(basename $0)) "
	PREFIX="`hostname`: "
	if [ $# -gt 1 ]; then
		ECHO_REQUESTED=$2
		
		if [ $ECHO_REQUESTED -gt $ECHO_LEVEL ]; then
			# in this case no output shall be produced
			return
		fi
	
		if [ $2 = $ECHO_ERROR ]; then
			PREFIX="${PREFIX}!!! ERROR !!!: "
		fi

		if [ $2 = $ECHO_WARNING ]; then
			PREFIX="${PREFIX} WARNING : "
		fi

		if [ $2 = $ECHO_NO_PREFIX ]; then
			PREFIX=""
		fi
	fi

	echo "${PREFIX}$1"
}

