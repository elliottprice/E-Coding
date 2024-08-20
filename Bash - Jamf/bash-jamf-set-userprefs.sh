#!/bin/zsh

# Disable Force Touch setting, Default "Reopen windows when logging back in" option on logout/shutdown to false/unchecked 
# Elliott Price | 2022

#Get current user
user=`ls -l /dev/console | awk '/ / { print $3 }'`

echo "User: " $user

plutil -replace ForceSuppressed -bool true /Users/$user/Library/Preferences/com.apple.AppleMultitouchTrackpad.plist
plutil -replace TALLogoutSavesState -bool false /Users/$user/Library/Preferences/com.apple.loginwindow.plist

# Restart the preference caching service to apply 

killall cfprefsd

exit 0