# Allow Standard users to edit the Desktop Shortcuts
# Elliott Price | 2023

$folderPath = "C:\Users\Public\Desktop"
$acl = Get-Acl $folderPath
$user = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-11')
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule ($user,"Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($rule)
Set-ACL $folderPath $acl