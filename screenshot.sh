#!/bin/bash

source ~/.secrets

MAIN_FOLDER="$HOME/Pictures/Screenshots"

FULL_DAY=$(date +'%A')
FULL_MONTH=$(date +'%B')
FULL_YEAR=$(date +'%Y')

HOUR=$(date +'%H')
MINUTE=$(date +'%M')
SECOND=$(date +'%S')

DAY=$(date +'%d')
MONTH=$(date +'%m')
YEAR=$(date +'%y')

FILE_NAME="${HOUR}-${MINUTE}-${SECOND}-${MONTH}-${DAY}-${YEAR}"
FOLDER_NAME="$FULL_YEAR/$FULL_MONTH/$FULL_DAY"

# Make folder(s)
mkdir -p ${MAIN_FOLDER}/${FOLDER_NAME}

# Take Screenshot
screencapture -x -s -C -m ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png

# Send Uploading Notification
osascript -e 'display notification "'"$FILE_NAME"'" with title "Uploading Screenshot"'

# Sleep for 1 seconds
sleep 1

# Upload Screenshot
FILE_URL=$(curl -F "file=@${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png" $UPLOADER_URL -H "token: $UPLOADER_TOKEN" -s)

# Copy URL to clipboard
echo $FILE_URL | pbcopy 

# Send Upload Notification
osascript -e 'display notification "'"$FILE_URL"'" with title "Uploaded Screenshot"'
