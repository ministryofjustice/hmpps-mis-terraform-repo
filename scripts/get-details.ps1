clear-host

Write-Output '--------------------------'
Write-Output 'hostname'
Write-Output '--------------------------'
hostname
Write-Output '--------------------------'
Write-Output 'computername'
Write-Output '--------------------------'
$env:computername

Write-Output '--------------------------'
Write-Output 'windows features'
Write-Output '--------------------------'
Get-WindowsFeature | Where { $_.InstallState -eq 'Installed'}

Write-Output '--------------------------'
Write-Output 'installed programs x32'
Write-Output '--------------------------'
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize

Write-Output '--------------------------'
Write-Output 'installed programs x64'
Write-Output '--------------------------'
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize

Write-Output '--------------------------'
Write-Output 'installed hotfixes'
Write-Output '--------------------------'
Get-HotFix

Write-Output '--------------------------'
Write-Output 'local users'
Write-Output '--------------------------'
Get-User | Format-Table –AutoSize
Write-Output '--------------------------'
Write-Output 'groups'
Write-Output '--------------------------'
Get-Group | Format-Table –AutoSize

Write-Output '--------------------------'
Write-Output 'local administrator group members'
Write-Output '--------------------------'
net localgroup administrators
 
