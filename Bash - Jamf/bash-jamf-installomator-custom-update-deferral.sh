#!/bin/zsh

#############################################################################################################
# This script will take a pre-set App Name from $4, check if the app is open, handle Deferrals,             #
# and update with Installomator                                                                             #
#                                                                                                           #
# by Elliott Price                                                                                          #
#                                                                                                           #
# Vers. 4.1 || May 2023                                                                                     #
#                                                 															#
#                                       																    #
# Supported Apps (Use these for the $4 Variable in the Jamf Policy)                     					#
# - Chrome																									#
# - Slack																									#
# - Zoom																									#
# - Firefox                                                                                                 #
#                                                                       								    #
#############################################################################################################

# Jamf Script Parameters: 
# 4 = App Name
# 5 = Trigger Day (number)
# 6 = Deferral Count

######################################### VARIABLES #########################################################

# Get selected App
APP_NAME="$4"
echo "> App passed to Script: $APP_NAME"

#Get current username and UID
USER=`ls -l /dev/console | awk '/ / { print $3 }'`
USERID=$(id -u $USER)

echo "> Current User: $USER "
echo "> Current UID: $USERID "

# Set app-specific variables - ADD NEW APPS HERE:
case $APP_NAME in
	Chrome) 
		echo "> Chrome selected" 
		APP_PATH="/Applications/Google Chrome.app"
		APP_PROCESS="Chrome"
		APP_LOGO="/usr/local/Images/Chrome.icns"
		INSTALLOMATOR_POLICY="installomator-chrome-silent"
	;;
	Slack) 
		echo "> Slack selected"
		APP_PATH="/Applications/Slack.app"
		APP_PROCESS="Slack"
		APP_LOGO="/usr/local/Images/Slack.icns"
		INSTALLOMATOR_POLICY="installomator-slack-silent"
	;;
	Zoom) 
		echo "> Zoom selected"
		APP_PATH="/Applications/Zoom.us.app"
		APP_PROCESS="zoom.us"
		APP_LOGO="/usr/local/Images/Zoom.icns"
		INSTALLOMATOR_POLICY="installomator-zoom-silent"
	;;
    Firefox) 
        echo "> Firefox selected"
        APP_PATH="/Applications/Firefox.app"
        APP_PROCESS="firefox"
        APP_LOGO="/Applications/Firefox.app/Contents/Resources/firefox.icns"
        INSTALLOMATOR_POLICY="installomator-firefox-silent"
    ;;
esac

# Check what day we should trigger on, build Day Variables
# Mon = 1, Sun = 7
TRIGGER_DAY="$5"
echo "> Trigger Day: $TRIGGER_DAY"

CURRENT_DAY=$(date +%u)
echo "> Current Day: $CURRENT_DAY"

TRIGGER_DAY_TEXT="none"

case $TRIGGER_DAY in
	1) 
		TRIGGER_DAY_TEXT="Monday"
	;;
	2) 
		TRIGGER_DAY_TEXT="Tuesday"
	;;
	3) 
		TRIGGER_DAY_TEXT="Wednesday"
	;;
	4) 
		TRIGGER_DAY_TEXT="Thursday"
	;;
	5) 
		TRIGGER_DAY_TEXT="Friday"
	;;
	6) 
		TRIGGER_DAY_TEXT="Saturday"
	;;
	7) 
		TRIGGER_DAY_TEXT="Sunday"
	;;
	
esac

echo "> Trigger day text: $TRIGGER_DAY_TEXT"

# Set Initial Deferral Count
INITIAL_DEFERRAL_COUNT="$6"
echo "> Deferral Count: $INITIAL_DEFERRAL_COUNT"

# Set Deferral File Location and Filename
deferralFolder="/Library/Application Support/JAMF/Deferrals"
deferralFile="${deferralFolder}/${APP_NAME}_deferralCount.txt"

echo "> DeferralFolder: $deferralFolder"
echo "> deferralFile: $deferralFile"

####################################### MESSAGING COPY ######################################################

# jamfHelper Title
deferralTitle="$APP_NAME Update Required By IT"

# jamfHelper Header message
deferralHeader="$APP_NAME Update Required"

# jamfHelper message - Dialog shown on the deferral prompt.
deferralMessage="An update for $APP_NAME is ready and available. 

Do you want to install this update now, or Defer to ask again later?

Note that this will restart $APP_NAME. Please save all your work and then click Upgrade when ready.\\n"

#Dialog shown on the no deferral prompt.
noDeferralHeader="Critical $APP_NAME updates will now install"
noDeferralMessage="An update for $APP_NAME is ready, and required to be installed.

Note that this will restart $APP_NAME - Save all your work and close"

######################################### FUNCTIONS ########################################################

# Check if app is running and update if not
check_running()
{
	echo "> Checking if process: $APP_PROCESS is running - check_running()"

    # Check on App process
    processCheck=$(pgrep process "$APP_PROCESS")

    echo "> Process Check: $processCheck"

    if [[ ! -z "$processCheck" ]];
    	then
        	# If app is running, go to additional checks & Deferral prompt
            echo "> $APP_NAME is running, prompt for upgrade - go back to main Script"

        else
        	# If the app isn't running, we can upgrade in the background
            echo "> $APP_NAME is not running. Upgrade silently..."
            
            # If Deferral file exists, Clean up Deferral File for next time...
        	if [ -f "$deferralFile" ];
				then 
					echo "> Deferral Exists, remove for next time"
					rm -rf $deferralFile
			fi

            # Call Installomator Silent script now
            echo "> Calling $INSTALLOMATOR_POLICY"
            jamf policy -trigger "$INSTALLOMATOR_POLICY"

            # Notify user that the App has been updated
            echo "> Notify user of update"
            "$helper" -windowType utility -windowPosition "ur" -icon "$APP_LOGO" -heading "$APP_NAME Update Complete" -description "$APP_NAME has been updated. Thank you!" -button1 "Exit" -defaultButton 1 -timeout 300

            echo "> We made it to the end! Exit"

			exit 0
	fi
}

# FOR CHROME ONLY - Restart Chrome
restart_Chrome()
{
    # Restart Chrome as the local user, using the Chrome restart command and launchctl asuser     

    echo "> Restarting Chrome as $USER ($USERID) with 'chrome://restart' Open command"

    /bin/launchctl asuser "$USERID" open -a "$APP_PATH" 'chrome://restart'

    # sudo -u $USER open -a "$APP_PATH" 'chrome://restart'
    # open -a "$APP_PATH" 'chrome://restart'

}

# Check on Deferrals
check_deferrals()
{
	echo "> Checking on Deferrals - check_deferrals()"

    ## Create the deferral folder if missing.
    if [ ! -d "$deferralFolder" ];
        then
            echo "> Initial Deferral folder isn't present. Creating..."
            mkdir "$deferralFolder"
    fi

    ## Read or create deferral File, but only on specified day:
    if [[ -f "$deferralFile" ]];
        then
            echo "> Deferral File Exists - Check the Deferrals remaining"
            deferralsLeft=$(cat "${deferralFile}")
            deferralCreated="No"
            echo "> User has: $deferralsLeft left."

    elif [[ "$CURRENT_DAY" == "$TRIGGER_DAY" ]];
    	then
            echo "> No Deferral Counter file found. Creating it with initial value of ${INITIAL_DEFERRAL_COUNT}... in $deferralFile"
            touch "$deferralFile"
            echo "$INITIAL_DEFERRAL_COUNT" > "$deferralFile"
            deferralsLeft="$INITIAL_DEFERRAL_COUNT"
            deferralCreated="Yes"
    else 
        	echo "> No deferral File exists, and it's not the selected Deferral Trigger day, wait."
        	deferralCreated="Don't create"
        	deferralsLeft="NA"
    fi
}

# Deferral Options and Messages
display_deferral_prompt()
{
    echo "> Display Deferral Prompt - display_deferral_prompt()"

    # Set Deferral Prompt Variables
    helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
    helperDeferralsLeft="\\nYou have $deferralsLeft deferral(s) remaining."
    countdownPrompt="Please make a selection in (H:M:S): "

    # Echo the description to preserve formatting when we call it during the jamfHelper message.
    helperDescription="$( echo "$deferralMessage$helperDeferralsLeft" )"

	killall jamfHelper
	wait 2>/dev/null
    helperReturn=$( "$helper" -windowType hud -icon "$APP_LOGO" -lockHUD -title "$deferralTitle" -alignTitle center -heading "$deferralHeader" -alignHeading left -description "$helperDescription" -alignDescription left -button2 "Update" -button1 "Defer" -defaultButton 2 -timeout 900 -countdown -countdownPrompt "$countdownPrompt" -alignCountdown center)
        

    if [[ $helperReturn == "239" ]]; then
            echo "> User force-closed the prompt. Relaunching."
            display_deferral_prompt

    elif [[ $helperReturn == "2" ]]; then
            echo "> User chose to upgrade."
            
            echo "> Run Installomator Update, Notify User when complete, and remove Deferral File"

            # call Installomator Silent script now
            jamf policy -trigger "$INSTALLOMATOR_POLICY"

            # Check if CHROME is being updated and re-open if so
            if [[ $APP_NAME == "Chrome" ]];
                then
                    # Open Chrome
                    echo "> Chrome is being updated, call the restart_Chrome() function to tell Chrome to restart and apply update"
                    restart_Chrome
            fi

            # Clean up Deferral File for next time... 
            rm -rf $deferralFile

            # Notify the User that the app is updated
            "$helper" -windowType hud -icon "$APP_LOGO" -heading "$APP_NAME Update Complete" -description "$APP_NAME has been updated. Thank you!" -button1 "Done" -defaultButton 1 -timeout 300

            echo "> We made it to the end!"

            exit 0

        else
            echo "> User deferred. Next check will be at the execution frequency interval defined in this policy."
            newDeferralCount=$((deferralsLeft-1))
            echo "> $newDeferralCount deferrals remaining."   
            echo "$newDeferralCount" > "$deferralFile"

            exit 0
    fi
}

display_noDeferral_prompt()
{  
    echo "> Display Deferral Prompt - display_noDeferral_prompt()"

    helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
    helperDeferralsLeft="\\nYou have no deferrals remaining, and $APP_NAME will now update."
    countdownPrompt="$APP_NAME will close in (H:M:S): "

    #Echo the description to preserve formatting when we call it during the jamfHelper message.
    helperDescription="$( echo "$noDeferralMessage$helperDeferralsLeft" )"

	killall jamfHelper
	wait 2>/dev/null
    helperReturn=$( "$helper" -windowType hud -icon "$APP_LOGO" -lockHUD -title "$deferralTitle" -alignTitle center -heading "$noDeferralHeader" -alignHeading left -description "$helperDescription" -alignDescription left -button1 "Update" -defaultButton 1 -timeout 1800 -countdown -countdownPrompt "$countdownPrompt" -alignCountdown center)
        

    if [[ $helperReturn == "239" ]]; then
            echo "> User force-closed the prompt. Resistance is futile."
            display_noDeferral_prompt

    elif [[ $helperReturn == "0" ]]; then
            echo "> User forced to upgrade."
            
            echo "> Run Installomator Update, Notify User when complete, and remove Deferral File"

            # call Installomator Silent script now
            jamf policy -trigger "$INSTALLOMATOR_POLICY"

                        # Check if CHROME is being updated and re-open if so
            if [[ $APP_NAME == "Chrome" ]];
                then
                    # Open Chrome
                    echo "> Chrome is being updated, call the restart_Chrome() function to tell Chrome to restart and apply update"
                    restart_Chrome
            fi

            # Clean up Deferral File for next time... 
            rm -rf $deferralFile

            # Notify the User that the app is updated
            "$helper" -windowType hud -icon "$APP_LOGO" -heading "$APP_NAME Update Complete" -description "$APP_NAME has been updated. Thank you!" -button1 "Done" -defaultButton 1 -timeout 300

            echo "> We made it to the end!"

            exit 0

    else
            echo "> Jamf Helper exit code: $helperReturn"
            exit 1
    fi
}

############################################ MAIN SCRIPT ###########################################################

# Check if app is running - if app is not running, silently update in the background no matter what day it is, or how many Deferrals are left
check_running

# App is running, now check if it's time to start the update and deferral process based on the provided day
check_deferrals

# Check the day, and deferral file status to see if it's time to prompt the user for upgrade

# If there's no deferrals left, display the display_noDeferral_prompt() and force update
# Else if the current day is the Trigger day, and the Deferral is newly created - run first deferral and start the Deferral process
# Else if there's any deferrals left and it's any day, show the Deferral prompt to continue the process

echo "> Check all the conditions to see what action should be taken:"
echo "- DeferralCreated: $deferralCreated"
echo "- DeferralsLeft: $deferralsLeft"
echo "- Trigger Day: $TRIGGER_DAY"
echo "- Current Day: $CURRENT_DAY"

# Deferral already exists, and User has no deferrals - Force Run! (Whether it's selected day or not)
if [[ "$deferralCreated" == "No" ]] && [[ "$deferralsLeft" -eq 0 ]];
	then 
		echo "> It's any day and the user has 0 deferrals left - Force update"
		display_noDeferral_prompt

# It's the Trigger Day and the Deferral file was just created - Start the Deferral process
elif [[ "$CURRENT_DAY" == "$TRIGGER_DAY" ]] && [[ "$deferralCreated" == "Yes" ]];
	then
		
		echo "> It's $TRIGGER_DAY_TEXT, and the Deferral was created - run update with Deferral"

		display_deferral_prompt

# User has started the deferral process, run no matter what day it is:
elif [[ "$deferralCreated" == "No" ]] && [[ "$deferralsLeft" -ge 1 ]];
	then
		
		echo "> It's any day and the User has deferrals - Run update with Deferral"
		display_deferral_prompt

# If the App is running, the user hasn't started the Deferral process, and it's not the selected day - Exit and wait for the next run.
else
	echo "> $APP_NAME is running, and it's not the selected day to start the deferral process - check again on next run."
	exit 0

fi
