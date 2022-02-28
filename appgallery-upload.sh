#!/bin/bash -e

if [ ! $1 ]; then 
  echo "Usage: $0 /file/to/upload"
  exit
fi

# Take from AppGallery connect site.
client_id="<Client ID number>"
key="<Cleint ID password string>"
appId="<appid number>"

file_to_upload="$1"
file_name=$(echo $file_to_upload | xargs basename)
# APK, RPK, PDF, JPG, JPEG, PNG, BMP, MP4, MOV, and AAB
file_suffix=$(echo $file_name | sed 's/.*\.//')


print_resp() { 
  echo "##########################"
  echo "$RESULT" |  jq 
  echo "##########################"
}

## 1. GET TOKEN
RESULT=$(curl -X POST https://connect-api.cloud.huawei.com/api/oauth2/v1/token \
-H "Content-Type: application/json" -H "Host: connect-api.cloud.huawei.com" \
-d "{ \"grant_type\":\"client_credentials\", \"client_id\":\"$client_id\", \"client_secret\":\"${key}\" }")

TOKEN=$(echo $RESULT | jq -r .access_token)

## 2. GET Upload URL and authCode
RESULT=$(curl "https://connect-api.cloud.huawei.com/api/publish/v2/upload-url?appId=${appId}&amp;suffix=${file_suffix}" \
-H "client_id: ${client_id}" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json")
print_resp

UPLOAD_URL=$(echo $RESULT | jq -r .uploadUrl)
AUTH_CODE=$(echo $RESULT | jq -r .authCode)


## 3. Upload file, -F implicitly means Content-Type: multipart/form-data
RESULT=$(curl "${UPLOAD_URL}" \
-F "file=@/${file_to_upload}" \
-F "authCode=${AUTH_CODE}" \
-F "fileCount=1" \
-F "filename=\"${file_name}\"")

print_resp
downloadURL=$(echo $RESULT |  jq -r '.[].UploadFileRsp.fileInfoList[].fileDestUlr')

## 4. Updating App File Information
# https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-References/agcapi-app-file-info-0000001111685202

curl -X PUT "https://connect-api.cloud.huawei.com/api/publish/v2/app-file-info?appId=${appId}&releaseType=3" \
-H "Content-Type: application/json" \
-H "client_id: $client_id" \
-H  "Authorization: Bearer ${TOKEN}" \
-d \
"{
       \"fileType\":5,
       \"files\":{
              \"fileName\":\"${file_name}\",
              \"fileDestUrl\":\"${downloadURL}\"
       }
}"

