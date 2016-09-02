#!/bin/bash

#
# DESCRIPTION:	This is server side configuration file to define environment variables
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

source /home/roman/mom_performance/hosts.sh
export JAVA_HOME=/home/roman/jdk1.8.0_31
export ACTIVEMQ_CLASSPATH=$AMQ_INSTALL_DIR/lib/optional/leveldbjni-1.8.jar
export ACTIVEMQ_OPTS_MEMORY="-Xms4G -Xmx4G"