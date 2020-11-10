[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#--------------------------------------------------------------------------
# create temp folder for downloading amazon cloudwatch agent
#--------------------------------------------------------------------------
#New-Item c:\temp -ItemType Directory -ErrorAction Ignore
Invoke-WebRequest -Uri 'https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi' -OutFile 'c:\cloudwatch_installer\amazon-cloudwatch-agent.msi'
#--------------------------------------------------------------------------
Start-Process msiexec.exe -Wait -ArgumentList '/i c:\cloudwatch_installer\amazon-cloudwatch-agent.msi'
#--------------------------------------------------------------------------
# start agent (for testing)
#--------------------------------------------------------------------------
cd 'C:\Program Files\Amazon\AmazonCloudWatchAgent'
pwd
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:C:\cloudwatch_installer\config.json -s
