clear-host


function SetPolicySetting {
 param( 
    [string]$Filename, 
    [string]$SettingName,
    [string]$Username 
 )
 
     Write-Output ">> SetPolicySetting Filename: $Filename, SettingName: $SettingName, Username: $Username"

     $file = Get-Content $Filename
     $containsWord = $file | %{$_ -match $SettingName}
     $file = $null
     
     if ($containsWord -contains $true) {
     
         Write-Host "> PolicySetting $SettingName exists, updating.."
         (gc "$Filename") -replace "^$SettingName .+", "`$0,$Username" | sc "$Filename"
     
     } else {
     
        Write-Host "> PolicySetting $SettingName doen't exist, creating.."
        (Get-Content $Filename) | 
            Foreach-Object {
                $_ # send the current line to output
                if ($_ -match "[Privilege Rights]") 
                {
                    #Add Lines after the selected pattern 
                    "$SettingName = $Username"

                }
            } | Set-Content $fileName
                     
     }
     
     Write-Output ">$(Get-Content $Filename | Select-String -Pattern $SettingName)"
}

$tempfile = 'c:\secpol.cfg'

Write-Output "Exporting existing security policy to $tempfile"
secedit /export /cfg $tempfile

$Username = "BOSSO-NDL-001"
$objUser = New-Object System.Security.Principal.NTAccount($username)
$Usersid = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$Usersid.Value

Write-Output '-----------------------------------'
Write-Output 'Updating security policy settings'
Write-Output '-----------------------------------'
# Get the available policies from:
# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/dd349804(v=ws.10)?redirectedfrom=MSDN

Write-Host "Enable SeServiceLogonRight for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeServiceLogonRight' -Username $Username
   
Write-Host "Enable SeBatchLogonRight for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeBatchLogonRight' -Username $Username

Write-Host "Enable SeNetworkLogonRight for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeNetworkLogonRight' -Username $Username

Write-Host "Enable SeInteractiveLogonRight for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeInteractiveLogonRight' -Username $Username

Write-Host "Enable SeTcbPrivilege for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeTcbPrivilege' -Username $Username

Write-Host "Enable SeBackupPrivilege for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeBackupPrivilege' -Username $Username

Write-Host "Enable SeRestorePrivilege for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeRestorePrivilege' -Username $Username

Write-Host "Enable SeEnableDelegationPrivilege for $Username"
SetPolicySetting -Filename $tempfile -SettingName 'SeEnableDelegationPrivilege' -Username $Username

Write-Output '-----------------------------------'
Write-Output 'Validating policy changes'
Write-Output '-----------------------------------'
secedit /validate c:\secpol.cfg

Write-Output '-----------------------------------'
Write-Output 'Saving policy changes'
Write-Output '-----------------------------------'
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg

Write-Output '-----------------------------------'
Write-Output 'Deleting temp security policy file c:\secpol.cfg'
Write-Output '-----------------------------------'
rm -force c:\secpol.cfg -confirm:$false  
 
