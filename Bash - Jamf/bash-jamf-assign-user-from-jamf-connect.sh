#!/bin/zsh

# Assign User in Jamf based on Jamf Connect logged in user's email address
# Elliott Price | 2022

# Get username
userName=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

# Get the Jamf Connect username from user's Jamf Connect plist file
localUserEmail=$(defaults read /Users/$userName/Library/Preferences/com.jamf.connect.state.plist DisplayName)


echo "Jamf Connect email is: $localUserEmail"

# Assign to user in Jamf 
jamf recon -endUsername $localUserEmail