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
FLAGS="-r"
if [ "$1" != "" ]; then; FLAGS="-ws"; else FLAGS="-rs"; fi
xfce4-screenshooter ${FLAGS} ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png

if [ ! -e ${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png ]; then exit 0; fi

# Send Uploading Notification
/usr/bin/notify-send "DCS File Upload" "Uploading screenshot"

# Upload file to custom api
UPLOAD=`http --multipart --ignore-stdin POST ${PERSONAL_API_HOST}/upload/image authorization:$(jwt dustin.sh/api ${PERSONAL_API_INTERNAL_SECRET} 60) file@${MAIN_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.png`

# Get file url
FILE_URL=$(echo $UPLOAD | jq .data | cut -d "\"" -f 2)

# Copy URL to clipboard
echo $FILE_URL | xsel --input --clipboard
echo $FILE_URL | xsel

# Send Upload Notification
notify-send "DCS File Upload" "File uploaded ${FILE_URL}"
