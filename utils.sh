#!/bin/bash

# DESCRIPTION:	Shared reusable generic functions for the project
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)

set -o nounset
set -o errexit

ECHO_NONE=0
ECHO_NO_PREFIX=1
ECHO_ERROR=1
ECHO_WARNING=2
ECHO_INFO=3
ECHO_DEBUG=4

# Set the current DEBUG level to one of the values listed above
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