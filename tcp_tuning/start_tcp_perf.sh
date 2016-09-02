#!/bin/bash

# Some useful tips about error checking in bash found here: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# This prevents running the script if any of the variables have not been set
#set -o nounset
# This automatically exits the script if any error occurs while running it
#set -o errexit

#############################################
# MAIN BODY starts here
#############################################
echo "------------------------------------------------------------------------------"
echo " This script starts IPERF "
echo "------------------------------------------------------------------------------"

IPERF_OPTIONS="-m"
#IPERF_OPTIONS="-m -w64K"

echo "Kill any existing iperf instances..."
kill -9 $(ps aux | grep '[i]perf' | awk '{print $2}')

echo "Starting new iperf (server or client - depending on the command line..."
iperf $1 $IPERF_OPTIONS

echo "DONE: script $BASH_SOURCE $1"
