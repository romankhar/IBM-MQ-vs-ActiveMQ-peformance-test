#!/bin/bash

#
# DESCRIPTION: 	This script makes a backup copy of the project zipped with time stamp into the local backup directory
# AUTHOR:   	Roman Kharkovski (http://whywebsphere.com/resources-links)
#

# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

source /home/roman/mom_performance/hosts.sh

PROJECT_NAME=mom_performance
DEST=$HOME/backup

if [ ! -d "$DEST" ]; then
	mkdir $DEST
fi

BACKUP_FILE=$DEST/${PROJECT_NAME}_`date +%s`
echo""
echo "Making new backup of the '$PROJECT_DIR' into the '$BACKUP_FILE'..."
zip -r $BACKUP_FILE $PROJECT_DIR
echo "Backup complete. Content of the $DEST folder is listed below:"
dir -l -t $DEST
echo ""