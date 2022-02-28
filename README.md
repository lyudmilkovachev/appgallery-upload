# AppGallery upload file
Bash script to upload files to Huawei AppGallery. You can use it as example how AppGallery API is working. 

## Prerequisits 
Prepare from AppGallery connect site the following values: 
- client_id - you have to go to "Users and permissions" / "AppGallery Connect API" and create API client
- key or password - from API client
- appId - ID of preliminary created App
- Installed curl and jq -  check your distribution

Edit script and update the values in the script header. 

## Usage
The script uses four steps to upload the file: 
1. Get token
2. Get upload URL and authCode
3. Upload file
4. Update App File Information

`$ ./appgallery-upload.sh /path/to/file`

Sadly, when updating file information, the following error is received but the file was uploded: 
>{ <br>
>  "ret": { <br>
>    "code": 204144647, <br>
>    "msg": "[cds]update service failed, additional msg is [OnShelf service not exist, update phased service failed.]" <br>
>  } <br>
>} <br>
