# Powershell script to remove Dell Digital Delivery program
# Elliott Price | 2023

# Check and create custom Log file

$Logfile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\delldd-remove.log"

If (Test-Path $Logfile){

  # // File exists

  $preMessage = "Log file exists - continue"

}Else{

  New-Item -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\delldd-remove.log"

  $preMessage = "Log file did not exist - created."

}

# Function to write to our Log file

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

# Pop out some starting logs

LogWrite "Starting Script on: $(Get-Date -Format u)"
LogWrite $preMessage

# Detect, and remove Dell Digital Delivery if it exists

if ($null -eq (Get-Package -Name "*Dell Digital Delivery*")) {

	LogWrite "Dell Digital Delivery software not found, exit"

	Exit 0

} Else {

	LogWrite "Dell Digital Delivery software found"

    try{
        # install NuGet

        LogWrite "Installing NuGet v2.8.5.208 for Uninstall-Package command"

        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force
    }

    catch{

        Write-Error "Error installing NuGet"

    }

    try{
        LogWrite "Attempt to uninstall Dell Digital Delivery"

        Get-Package -Name "*Dell Digital Delivery*"  | Uninstall-Package -ErrorAction stop

        LogWrite "Dell Digital Delivery software successfully uninstalled"

        }

    catch{

        Write-Error "Error uninstalling Dell Digital Delivery software"

        LogWrite "Error uninstalling Dell Digital Delivery software"

        }

	Exit 0

}