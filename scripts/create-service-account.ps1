$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    Write-Host('Fetching Environment details from Instance Metadata')
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment name and application from this instance's environment-name and application tag values
    $environment = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment"
        }
    )

    $environment.Value.ToUpper()

    $username = "DS_AD_$($environment.Value.ToUpper())_001"
    
    $onetimepassword = "MustBeChanged0!"
   
    Write-Host("Creating user: $username")
    $creds = New-Credential -UserName $username -Password $onetimepassword
    Install-User -Credential $creds -PasswordExpires 
    Write-Host("Adding user: $username to local Administrators Group")
    Add-GroupMember -Name Administrators -Member $username
    
    Write-Host("Updating user: $username to change password on first logon")
    # Limited by version of powershell - need to use net cmd to force password change
    net user $username /logonpasswordchg:yes


}
catch [Exception] {
    Write-Host ('Failed to create service account user')
    echo $_.Exception|format-list -force
    exit 1
} 
