# Set Windows 11 Taskbar to Align Left (Classic layout)
# Elliott Price | 2023

# Check and create custom Log file

$Logfile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\w11tb.log"

If (Test-Path $Logfile){

  # File exists

  $preMessage = "Log file exists - continue"

}Else{

  New-Item -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\w11tb.log"

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

# Check if device is running Windows11 and set HKEY value if so

if(-not (Get-CimInstance Win32_OperatingSystem -Property *).Caption -like "*Windows 11*"){

    LogWrite "Not windows 11 - Exit 0"

    Exit 0

} Else {

    LogWrite "Device is on Windows 11, Set Taskbar alignment to Left (0)" 

    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $value = "TaskbarAl"
    $setCreate = "Set"

    # Try to get DWORD value to see if it exists, if not tell script to create

    try {
    
        Get-ItemPropertyValue -path $path -name $value -ErrorAction Stop
    
    } catch {
        
        LogWrite "HKEY not preset, create instead of set"
        $setCreate = "Create"

    }

    LogWrite "Set or Create?"
    LogWrite $setCreate

    if($setCreate -eq "Set"){

            LogWrite "HKEY Detected, set key"

            try {

                Set-ItemProperty -Path $path -Name $value -Value 0 -Force -ErrorAction Stop

            } catch {
            
                LogWrite "Error setting HKEY:"
                LogWrite $Error

            }

        } elseif($setCreate -eq "Create") {
        
            LogWrite "HKEY not detected, Create key"

            try {

                New-ItemProperty -Path $path -Name $value -Value 0 -Force -ErrorAction Stop 

            } catch {
            
                LogWrite "Error creating HKEY:"
                LogWrite $Error

            }

        }

        # Check HKEY value to verify if it is properly set: 

        $taskbarAlign = Get-ItemProperty -path $path -Name $value
        $taskbarAlValue = (Get-ItemProperty -path $path -Name $value).TaskbarAl
        #$taskbarAlValue = $taskbarAlign.TasbarAl

        LogWrite "HKEY value after create or set: "
        LogWrite $taskbarAlValue

        if ($taskbarAlign.TaskbarAl -eq 0) {

            LogWrite "Success - Exit 0"

            Exit 0

        } else {

            LogWrite "Failure - Exit 1"

            Exit 1
        }

}   
