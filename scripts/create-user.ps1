$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

try {
    
    # Get the instance id from ec2 meta data
    $instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"
    # Get the environment from this instance's environment tag value
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
    
    $onetimepassword = "MustBeChanged0!"
    $username = "DS_AD_$($environment.Value.ToUpper())_001"

    Write-Host("Creating user: $username")
    $creds = New-Credential -UserName $username -Password $onetimepassword
    Install-User -Credential $creds 
    
    Write-Host("Adding user $username to local Administrators group")
    Add-GroupMember -Name Administrators -Member $username

    # Limited by version of powershell - need to use net cmd to force password change
    #net user $user /logonpasswordchg:yes
    
}
catch [Exception] {
    Write-Host ('Failed to install IM Interface service')
    echo $_.Exception|format-list -force
    Exit 1
} 
