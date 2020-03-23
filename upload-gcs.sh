#!/bin/bash

source ~/.secrets

MAIN_FOLDER="$HOME/Pictures/Uploads"

BUCKET_NAME="gcs.dustin.sh"
UPLOADS_FOLDER="u"

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

# Upload and set public
gcloud config set pass_credentials_to_gsutil false
BOTO_CONFIG=/Users/byte/.dustin-mac-screenshot-boto gsutil cp ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.${FILE_EXT} gs://${BUCKET_NAME}/${UPLOADS_FOLDER}/${SHA256:8:16}.${FILE_EXT}
BOTO_CONFIG=/Users/byte/.dustin-mac-screenshot-boto gsutil acl ch -u AllUsers:r gs://${BUCKET_NAME}/${UPLOADS_FOLDER}/${SHA256:8:16}.${FILE_EXT}
gcloud config unset pass_credentials_to_gsutil

# File URL
FILE_URL="https://${BUCKET_NAME}/${UPLOADS_FOLDER}/${SHA256:8:16}.${FILE_EXT}"

# Copy URL to clipboard
echo $FILE_URL | pbcopy 

# Send Upload Notification
osascript -e 'display notification "'"$FILE_URL"'" with title "Uploaded Screenshot"'
