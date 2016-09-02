#!/bin/bash
# This prevents running the script if any of the variables have not been set
set -o nounset
# This automatically exits the script if any error occurs while running it
set -o errexit

PROJECT_DIR=mom_performance
SOURCE=$HOME/$PROJECT_DIR
DEST=$HOME/backup

if [ ! -d "$DEST" ]; then
	mkdir $DEST
fi

BACKUP_FILE=$DEST/${PROJECT_DIR}_`date +%s`
echo""
echo "Making new backup of the '$SOURCE' into the '$BACKUP_FILE'..."
zip -r $BACKUP_FILE $SOURCE
echo "Backup complete. Content of the $DEST folder is listed below:"
dir -l -t $DEST
echo ""
