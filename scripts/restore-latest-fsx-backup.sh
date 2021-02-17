#!/usr/bin/env bash

REGION=eu-west-2
FILESYSTEMID=$2


ENV_TYPE=$1     
ENVIRONMENTNAME=delius-${ENV_TYPE}
SUBNETNAMEA=${ENVIRONMENTNAME}-private-eu-west-2a-subnet
SUBNETNAMEB=${ENVIRONMENTNAME}-private-eu-west-2b-subnet



profile=restore

if [[ -z $ENV_TYPE ]]; then
  echo '--------------------------------------------------------------------------------------------------------'
  echo "Usage $0 ENV_TYPE  "
  echo "ENV_TYPE: mis-dev | auto-test | stage| pre-prod | prod"
  echo "Please note the latest snapshot is restored"
  echo '--------------------------------------------------------------------------------------------------------'
  exit 1
fi

#Functions
set_account_id () {

case "${ENV_TYPE}" in
    mis-dev)   ACCOUNT_ID="479759138745"
               ;;
    auto-test) ACCOUNT_ID="431912413968"
               ;;
    stage)     ACCOUNT_ID="205048117103"
    ;;
    pre-prod)  ACCOUNT_ID="010587221707"
    ;;
    prod)      ACCOUNT_ID="050243167760"
    ;;
    *)         echo "${ENV_TYPE} is not setup for snapshot restores"
               exit 1
               ;;
esac
echo "AccountID: $ACCOUNT_ID"
}

authenticate ()
{
mkdir -p ${HOME}/.aws
echo "Assuming role: arn:aws:iam::${ACCOUNT_ID}:role/terraform "
echo "aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_ID}:role/terraform --role-session-name restore-session --duration-seconds 3600"
temp_role=$(aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_ID}:role/terraform --role-session-name restore-session --duration-seconds 3600)
aws_access_key_id=$(echo ${temp_role} | jq .Credentials.AccessKeyId | xargs)
aws_secret_access_key=$(echo ${temp_role} | jq .Credentials.SecretAccessKey | xargs)
aws_session_token=$(echo ${temp_role} | jq .Credentials.SessionToken | xargs)

cat << EOF > ${HOME}/.aws/credentials

[${profile}]
aws_access_key_id = ${aws_access_key_id}
aws_secret_access_key = ${aws_secret_access_key}
aws_session_token = ${aws_session_token}

EOF

}

get_subnet_id_for_name ()   {

  if [[ -z $1 ]]; then
    echo '--------------------------------------------------------------------------------------------------------'
    echo "SubnetName not passed as arg1"
    echo '--------------------------------------------------------------------------------------------------------'
    exit 1
  fi  

  SUBNETID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$1" --query 'Subnets[0].SubnetId')
  echo "$SUBNETID" | sed -e 's/^"//' -e 's/"$//'

}

get_security_group_id_for_name() {

  if [[ -z $1 ]]; then
    echo '--------------------------------------------------------------------------------------------------------'
    echo "SecurityGroup Name not passed as arg1"
    echo '--------------------------------------------------------------------------------------------------------'
    exit 1
  fi  

  SUBNETID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=$1" --query 'SecurityGroups[0].GroupId')
  echo "$SUBNETID" | sed -e 's/^"//' -e 's/"$//'

}

get_random_client_request_token() {

  echo '--------------------------------------------------------------------------------------------------------'
  echo 'Getting a random ClientRequestToken'
  echo '--------------------------------------------------------------------------------------------------------'
  CRT=$(uuidgen)
  echo "$CRT" | sed -e 's/^"//' -e 's/"$//'

}

get_windows_configuration() {

  echo '--------------------------------------------------------------------------------------------------------'
  echo 'Getting Windows Configuration'
  echo '--------------------------------------------------------------------------------------------------------'



  $CFG= "{
    "ActiveDirectoryId": "$1",
    "SelfManagedActiveDirectoryConfiguration": {
      "DomainName": "$2",
      "OrganizationalUnitDistinguishedName": "$3",
      "FileSystemAdministratorsGroup": "$4",
      "UserName": "$5",
      "Password": "$6",
      "DnsIps": ["string", ...]
    },
    "DeploymentType": "MULTI_AZ_1",
    "PreferredSubnetId": "string",
    "ThroughputCapacity": integer,
    "WeeklyMaintenanceStartTime": "string",
    "DailyAutomaticBackupStartTime": "string",
    "AutomaticBackupRetentionDays": integer,
    "CopyTagsToBackups": true,
    "Aliases": ["string", ...]
  }"

  echo $CFG
}


get_tags() {

  echo '--------------------------------------------------------------------------------------------------------'
  echo 'Getting Tags'
  echo '--------------------------------------------------------------------------------------------------------'

  $TAGS='[
    {
      "Key": "string",
      "Value": "string"
    }
  ]'
  
}

get_latest_fsx_backup ()   
{
    
    echo '--------------------------------------------------------------------------------------------------------'
    echo "Looking for backups for FileSystemId '$FILESYSTEMID'"
    echo '--------------------------------------------------------------------------------------------------------'
    BACKUPS=$(aws fsx describe-backups --output json --region eu-west-2 \
                --filters "Name=file-system-id,Values=$FILESYSTEMID" "Name=backup-type,Values=AUTOMATIC" \
                --query 'Backups[*].[CreationTime,BackupId,ResourceARN] | reverse(sort_by(@, &@[0])) [0]' )

    if [[ -z $BACKUPS ]]; then
        echo "No Instance ids found ...exiting"
        exit 1
    fi
    
    CREATIONTIME=$(jq -r '.[0]' <<< "$BACKUPS")
    BACKUPID=$(jq -r '.[1]' <<< "$BACKUPS")
    BACKUPARN=$(jq -r '.[2]' <<< "$BACKUPS")

    echo "CREATIONTIME: ${CREATIONTIME}"
    echo "BACKUPID    : ${BACKUPID}"
    echo "BACKUPARN   : ${BACKUPARN}"

}


create-file-system-from-backup ()
{

  echo '--------------------------------------------------------------------------------------------------------'
  echo "Creating FSx FileSystem from backup"
  echo "--backup-id '$BACKUPID'"
  echo "--subnet-ids '$PRIMARYSUBNETID', '$SECONDARYSUBNETID'
  echo "--security-group-ids '$SECURITYGROUPID'"
  echo "--tags [$TAGS]"
  echo "--windows-configuration $WINDOWSCONFIGURATION"
  echo "--storage-type $STORAGETYPE"
  echo "--client-request-token $CLIENTREQUESTTOKEN"
  

  echo '--------------------------------------------------------------------------------------------------------'
  echo ''
    # aws fsx create-file-system-from-backup \
    #       --backup-id $BACKUPID \ 
    #       --subnet-ids $SUBNETIDS \
    #       --security-group-ids $SECURITYGROUPID \
    #       --tags $TAGS \
    #       --windows-configuration <value> \
    #       --storage-type <value>]
    #       --client-request-token $CLIENTREQUESTTOKEN

}


##MAIN
set_account_id
#authenticate_local
get_latest_fsx_backup

    
echo '--------------------------------------------------------------------------------------------------------'
echo "Getting subnetId for $SUBNETNAMEA"
echo '--------------------------------------------------------------------------------------------------------'
PRIMARYSUBNETID=$(get_subnet_id_for_name $SUBNETNAMEA)
if [[ -z $PRIMARYSUBNETID ]]; then
    echo "No Primary Subnet id found for subnet ${SUBNETNAMEA} ...exiting"
    exit 1
fi
echo "Primary Subnet Id found for AccountID: ${ACCOUNT_ID}, subnet ${SUBNETNAMEA}"
echo "$PRIMARYSUBNETID"

echo '--------------------------------------------------------------------------------------------------------'
echo "Getting subnetId for $SUBNETNAMEB"
echo '--------------------------------------------------------------------------------------------------------'
SECONDARYSUBNETID=$(get_subnet_id_for_name $SUBNETNAMEB)
# SECONDARYSUBNETID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$SUBNETNAMEB" --query 'Subnets[0].SubnetId')

if [[ -z $SECONDARYSUBNETID ]]; then
    echo "No Primary Subnet id found for subnet ${SUBNETNAMEB} ...exiting"
    exit 1
fi
echo "Secondary Subnet Id found for AccountID: ${ACCOUNT_ID}, subnet ${SUBNETNAMEB}"
echo "$SECONDARYSUBNETID"


echo '--------------------------------------------------------------------------------------------------------'
echo 'Getting Security Group Ids'
echo '--------------------------------------------------------------------------------------------------------'
# tf-eu-west-2-hmpps-delius-mis-dev-mis-fsx
SECURITYGROUPNAME="tf-eu-west-2-hmpps-${ENVIRONMENTNAME}-mis-fsx"
SECURITYGROUPID=$(get_security_group_id_for_name $SECURITYGROUPNAME)
echo "$SECURITYGROUPID"

get_tags

get_windows_configuration

CLIENTREQUESTTOKEN=$(get_random_client_request_token)
echo "${CLIENTREQUESTTOKEN}"

create-file-system-from-backup
