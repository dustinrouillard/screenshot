#!/bin/bash

#source ~/.secrets

MAIN_FOLDER="$HOME/Pictures/Screenshots"

BUCKET_NAME="gcs.dustin.sh"
SCREENSHOTS_FOLDER="i"

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

GCLOUD_PATH="/usr/local/bin/gcloud"
GSUTIL_PATH="/usr/local/bin/gsutil"

# Make folder(s)
mkdir -p ${MAIN_FOLDER}/${FOLDER_NAME}

# Take Screenshot
screencapture -x -s -C -m ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png

if [ ! -e ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png ]; then exit 0; fi

# Send Uploading Notification
osascript -e 'display notification "'"$FILE_NAME"'" with title "Uploading Screenshot"'

# Define file variables for name and base64
BASE64=$(cat ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png | base64)
SHA256=$(echo $BASE64 | openssl sha256)

# Upload and set public
$GCLOUD_PATH config set pass_credentials_to_gsutil false
BOTO_CONFIG=/Users/byte/.dustin-mac-screenshot-boto $GSUTIL_PATH cp ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png gs://${BUCKET_NAME}/${SCREENSHOTS_FOLDER}/${SHA256:8:16}.png
BOTO_CONFIG=/Users/byte/.dustin-mac-screenshot-boto $GSUTIL_PATH acl ch -u AllUsers:r gs://${BUCKET_NAME}/${SCREENSHOTS_FOLDER}/${SHA256:8:16}.png
$GCLOUD_PATH config unset pass_credentials_to_gsutil

# File URL
FILE_URL="https://${BUCKET_NAME}/${SCREENSHOTS_FOLDER}/${SHA256:8:16}.png"

# Copy URL to clipboard
echo $FILE_URL | pbcopy 

# Send Upload Notification
osascript -e 'display notification "'"$FILE_URL"'" with title "Uploaded Screenshot"'
