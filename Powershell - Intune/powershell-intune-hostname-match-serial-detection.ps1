# Powershell detection script to detect if HostName matches Serial
# Elliott Price | 2023

$hostname = hostname
$serial = (Get-CimInstance -ClassName CIM_BiosElement).SerialNumber

if( $serial -ne $hostname)
{Write-Host 'Hostname does not match Serial number - Remediate'
Exit 1} 

else {Write-Host 'Hostname matches serial number'
Exit 0}