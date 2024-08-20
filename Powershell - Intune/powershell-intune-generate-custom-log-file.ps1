# Script Component - Create Custom Log File for easier troubleshooting
# Elliott Price | 2023

# Check and create custom Log file

$Logfile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\<LOGFILE>.log"

If (Test-Path $Logfile){

  # File exists

  $preMessage = "Log file exists - continue"

}Else{

  New-Item -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\<LOGFILE>.log"

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