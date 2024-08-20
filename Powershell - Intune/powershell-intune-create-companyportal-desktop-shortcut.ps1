# Create Company Portal Shortcut on desktop
# Elliott Price | 2023

# Check and create custom Log file

$Logfile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\cp-shortcut.log"

If (Test-Path $Logfile){
  # File exists
  $preMessage = "Log file exists - continue"
}Else{

  New-Item -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\cp-shortcut.log"
  $preMessage = "Log file did not exist - created."
}

# Function to write to our Log file

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

# Starting logs

LogWrite "=========="
LogWrite "Starting Script on: $(Get-Date -Format u)"
LogWrite $preMessage

# Set up Variables

$TargetFile =  "C:\Windows\explorer.exe"
$ShortcutFile = "$env:USERPROFILE\Desktop\Company Portal.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.Arguments="shell:AppsFolder\Microsoft.CompanyPortal_8wekyb3d8bbwe!App"
$Shortcut.IconLocation = "C:\ProgramData\companyportal.ico"
$Shortcut.TargetPath = $TargetFile
$iconPath = "C:\ProgramData\companyportal.ico"

$cpURL = "<CUSTOM URL>/companyportal.ico"
$cpOutPath = "C:\ProgramData\companyportal.ico"

LogWrite "Shortcut Location:"
LogWrite $iconPath

# Download Company Portal shortcut icon

# Check if file exists 

if (Test-Path $cpOutPath) {
    LogWrite "Company Portal icon already exists, skipping download."

} else {
    
    try {
    
        Invoke-WebRequest $cpURL -OutFile $cpOutPath -ErrorAction stop
    
    } catch {
        
        LogWrite "Error downloading Company Portal icon"
        LogWrite $Error
        $exitCodeReturn = "error"

    }

    LogWrite "Company Portal icon downloaded successfully."
}

# Check to make sure the Icon has been downloaded first

If (Test-Path $iconPath) {

    LogWrite "Icon exists, create shortcut"

    $Shortcut.Save()

} else {
    
    $testIcon = "0"

    while ($testIcon = "0") {
        
        If (Test-Path $iconPath) {
            LogWrite "Icon is downloaded, create shortcut!"
            $testIcon = "1"

        } else {
            LogWrite "Icon doesn't exist; wait and try again"
            $testIcon = "0"

            sleep 10
        }
    
    }

    #Now create shortcut once icon is available: 

    $Shortcut.Save()

}