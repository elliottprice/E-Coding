#!/bin/zsh

# Reset Software updates to resolve "stuck" Updates
# Elliott Price | 2022

# Remove preference file
sudo rm /Library/Preferences/com.apple.SoftwareUpdate.plist

# If the install data folder exists, remove 
if [ -e /macOS\ Install\ Data ]
then
	sudo rm -rf "/macOS Install Data"
fi

sudo launchctl kickstart -k system/com.apple.softwareupdated