#!/bin/bash

type tar >/dev/null 2>&1 || { echo >&2 "tar is required but it's not installed. Aborting."; exit 1; }
type curl >/dev/null 2>&1 || { echo >&2 "curl is required but it's not installed. Aborting."; exit 1; }

TARGET_DIR="/docker/appdata/httpd/www/schwan.us/htdocs"
OWNER="www-data:www-data"
PERMISSIONS="644"

# Get the latest version of plezy
curl -fsSL --retry 3 https://github.com/edde746/plezy/releases/latest/download/plezy-android-armeabi-v7a.tar.gz -o plezy.tar.gz

# Unzip the downloaded file
tar -xzf plezy.tar.gz

# Move the plezy executable to the target directory and set permissions
sudo cp plezy.apk ${TARGET_DIR}/plezy.apk
sudo chown ${OWNER} ${TARGET_DIR}/plezy.apk
sudo chmod ${PERMISSIONS} ${TARGET_DIR}/plezy.apk

# Clean up
rm -rf plezy.apk plezy.tar.gz
echo "Plezy has been installed successfully!"
