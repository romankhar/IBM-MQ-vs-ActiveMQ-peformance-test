#!/bin/bash

#
# DESCRIPTION:	Definitions of host names for the rest of the project
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

set -o nounset
set -o errexit

#########################################
# DNS names of hosts that run the server side of the software - i.e. 'hostname.domain.com'
AMQ_HOST=amqhost
WMQ_HOST=mqhost

#########################################
# Installation paths - same across all machines
WMQ_INSTALL_DIR=/opt/mqm
export AMQ_INSTALL_DIR=/home/roman/apache-activemq-5.11.0

#########################################
# Users - same across all machines
REMOTE_USER=roman

#########################################
# Project path - same on all machines
PROJECT_DIR=/home/$REMOTE_USER/mom_performance