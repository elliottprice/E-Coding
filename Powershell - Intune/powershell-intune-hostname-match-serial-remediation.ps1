# Powershell remediation script to set HostName to Serial
# Elliott Price | 2023

$serial = (Get-CimInstance -ClassName CIM_BiosElement).SerialNumber
Rename-Computer -NewName "$serial3"