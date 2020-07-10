#!/bin/zsh

source ~/.secrets
source ~/.jwt

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

if [ ! -e ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png ]; then exit 0; fi

# Send Uploading Notification
osascript -e 'display notification "'"$FILE_NAME"'" with title "Uploading Screenshot"'

# Define file variables for name and base64
BASE64=$(cat ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png | base64)

# Upload file to custom api
UPLOAD=$(http --ignore-stdin POST http://127.0.0.1:1300/upload/image authorization:$(jwt dustin.sh/api ${PERSONAL_API_INTERNAL_SECRET} 20) file=\;base64,${BASE64})

# Get file url
FILE_URL=$(echo $UPLOAD | jq .data | cut -d "\"" -f 2)

# Copy URL to clipboard
echo $FILE_URL | pbcopy

# Send Upload Notification
osascript -e 'display notification "'"$FILE_URL"'" with title "Uploaded Screenshot"'
