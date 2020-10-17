#!/bin/bash

source ~/.secrets
source ~/.jwt

MAIN_FOLDER="$HOME/Pictures/Uploads"

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
FILE_EXT=${1##*.}

# Make folder(s)
mkdir -p ${MAIN_FOLDER}/${FOLDER_NAME}

# Move copy item
cp $1 ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.${FILE_EXT}

# Send Uploading Notification
osascript -e 'display notification "'"$FILE_NAME"'" with title "Uploading file"'

# Define file variables for name and base64
BASE64=$(cat ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.${FILE_EXT} | base64)
SHA256=$(echo $BASE64 | openssl sha256)

# Upload file to custom api
UPLOAD=$(http --ignore-stdin POST ${PERSONAL_API_HOST}/upload/file authorization:$(jwt dustin.sh/api ${PERSONAL_API_INTERNAL_SECRET} 20) file=\;base64,${BASE64})

# Get file url
FILE_URL=$(echo $UPLOAD | jq .data | cut -d "\"" -f 2)

# Copy URL to clipboard
echo $FILE_URL | pbcopy 

# Send Upload Notification
osascript -e 'display notification "'"$FILE_URL"'" with title "Uploaded Screenshot"'
