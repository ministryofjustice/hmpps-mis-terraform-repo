#!/usr/bin/env bash

REGION=eu-west-2
ENV_TYPE=$1     #mis-dev    #$1
HOST_TYPE=$2  #bws     #$2
profile=restore

if [[ -z $ENV_TYPE ]] || [[ -z $HOST_TYPE ]]; then
  echo '--------------------------------------------------------------------------------------------------------'
  echo "Usage $0 ENV_TYPE   HOST_TYPE"
  echo "ENV_TYPE: mis-dev | auto-test | stage| pre-prod | prod"
  echo "HOST_TYPE: bws | bcs | bps| bws | dis"
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
    pre-prod)  ACCOUNT_ID="010587221707 "
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


get_host_list ()   ##$1 is the host type ie bws
{
    #HOSTNAME=tf-${REGION}-hmpps-delius-${ENV_TYPE}-mis-ndl-${1}-*
    HOSTNAME=tf-${REGION}-hmpps-delius-${ENV_TYPE}-mis-ndl-${1}-102

    INSTANCE_IDS=$(aws ec2 describe-instances --output text --region "${REGION}" --profile $profile \
            --query 'Reservations[*].Instances[*].[InstanceId]' \
            --filters "Name=tag:Name,Values=$HOSTNAME")
    if [[ -z $INSTANCE_IDS ]]; then
        echo "No Instance ids found ...exiting"
        exit 1
    fi
    echo '--------------------------------------------------------------------------------------------------------'
    echo "Instance IDs found for AccountID:${ACCOUNT_ID} HOST TYPE:${HOST_TYPE} :"
    echo "$INSTANCE_IDS"
    echo '--------------------------------------------------------------------------------------------------------'
}


stop_instances ()
{
IFS=$'\n';for instance in $INSTANCE_IDS; do
  instance_id=$(echo "$instance" | awk '{ print $1 }')
  echo '--------------------------------------------------------------------------------------------------------'
  echo "Stopping instance $instance_id"
  echo '--------------------------------------------------------------------------------------------------------'
  echo "aws ec2 stop-instances --instance-ids $instance_id --profile $profile --region ${REGION}"
  sleep 10
  INSTANCE_STATUS=$(aws ec2 stop-instances --instance-ids $instance_id --profile $profile --region "${REGION}" | jq .StoppingInstances[0].CurrentState.Name)
  echo "$instance_id is in state: $INSTANCE_STATUS"
done
}


detach_old_volumes ()
{
  IFS=$'\n';for instance in $INSTANCE_IDS; do
    instance_id=$(echo "$instance" | awk '{ print $1 }')
    while [[ $INSTANCE_STATUS == "running" ]]
        do
            echo '--------------------------------------------------------------------------------------------------------'
            echo "$instance_id is not in stopped state ...retrying"
            echo '--------------------------------------------------------------------------------------------------------'
            sleep 30
            INSTANCE_STATUS=$(aws ec2 stop-instances --instance-ids $instance_id --profile $profile --region "${REGION}" | jq .StoppingInstances[0].CurrentState.Name)
            echo "$instance_id is in state: $INSTANCE_STATUS"
            if [[ "$INSTANCE_STATUS" == "stopped" ]]; then
                break
            fi
        done

    ROOT_VOLUME=$(aws ec2 describe-volumes      --filters Name=attachment.instance-id,Values=$instance_id  Name=attachment.device,Values=/dev/sda1 --profile $profile --region ${REGION} | jq -r .Volumes[0].VolumeId)
    SECONDARY_VOLUME=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$instance_id  Name=attachment.device,Values=/dev/xvdb --profile $profile --region ${REGION} | jq -r .Volumes[0].VolumeId)

    echo '--------------------------------------------------------------------------------------------------------'
    echo "Detaching Volumes: $ROOT_VOLUME  $SECONDARY_VOLUME  from $instance_id"
    echo '--------------------------------------------------------------------------------------------------------'
    echo "aws ec2 detach-volume --volume-id $ROOT_VOLUME      --profile $profile --region ${REGION}"
    sleep 10
    aws ec2 detach-volume --volume-id $ROOT_VOLUME      --profile $profile --region ${REGION} || exit $?
    echo "aws ec2 detach-volume --volume-id $SECONDARY_VOLUME --profile $profile --region ${REGION}"
    sleep 10
    aws ec2 detach-volume --volume-id $SECONDARY_VOLUME --profile $profile --region ${REGION} || exit $?
  done
}


attach_new_volumes ()
{
  #Attach root device
  echo '--------------------------------------------------------------------------------------------------------'
  echo "Attaching Volume: $ROOT_RESTORED_VOLUME_ID to $instance_id"
  echo '--------------------------------------------------------------------------------------------------------'
  echo "aws ec2 attach-volume --volume-id $ROOT_RESTORED_VOLUME_ID --device /dev/sda1  --instance-id $instance_id  --profile $profile --region ${REGION}"
  sleep 10
  aws ec2 attach-volume --volume-id $ROOT_RESTORED_VOLUME_ID --device /dev/sda1 --instance-id $instance_id  --profile $profile --region ${REGION}  || exit $?

  #Attach secondary device
  echo '--------------------------------------------------------------------------------------------------------'
  echo "Attaching Volume: $SECONDARY_RESTORED_VOLUME_ID to $instance_id"
  echo '--------------------------------------------------------------------------------------------------------'
  echo "aws ec2 attach-volume --volume-id $SECONDARY_RESTORED_VOLUME_ID --device /dev/xvdb --instance-id $instance_id  --profile $profile --region ${REGION}"
  sleep 10
  aws ec2 attach-volume --volume-id $SECONDARY_RESTORED_VOLUME_ID --device /dev/xvdb --instance-id $instance_id  --profile $profile --region ${REGION}  || exit $?
}


restore_snapshots ()
{
IFS=$'\n';for instance in $INSTANCE_IDS; do
  instance_id=$(echo "$instance" | awk '{ print $1 }')
    ROOT_VOLUME=$(aws ec2 describe-volumes      --filters Name=attachment.instance-id,Values=$instance_id  Name=attachment.device,Values=/dev/sda1 --profile $profile --region ${REGION} | jq -r .Volumes[0].VolumeId)
    SECONDARY_VOLUME=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$instance_id  Name=attachment.device,Values=/dev/xvdb --profile $profile --region ${REGION} | jq -r .Volumes[0].VolumeId)
    SNAPSHOT_ARN_ROOT=$(aws backup list-recovery-points-by-backup-vault  --backup-vault-name delius-${ENV_TYPE}-${HOST_TYPE}-ec2-bkup-pri-vlt  --profile $profile --region $REGION  --max-results 1  --by-resource-arn arn:aws:ec2:eu-west-2:$ACCOUNT_ID:volume/$ROOT_VOLUME | jq -r .RecoveryPoints[0].RecoveryPointArn)
    SNAPSHOT_ARN_SECONDARY=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name delius-${ENV_TYPE}-${HOST_TYPE}-ec2-bkup-pri-vlt --profile $profile --region $REGION --max-results 1 --by-resource-arn arn:aws:ec2:eu-west-2:$ACCOUNT_ID:volume/$SECONDARY_VOLUME | jq -r .RecoveryPoints[0].RecoveryPointArn)
    INSTANCE_AZ=$(aws ec2 describe-instances --instance-ids $instance_id --profile $profile --region $REGION --output text --query 'Reservations[*].Instances[*].Placement.[AvailabilityZone]')

    #Restore  volumes and obtain restore job ID
    echo '--------------------------------------------------------------------------------------------------------'
    echo "Restoring devices: /dev/sda1 & /dev/xvdb concurrently for $instance_id"
    echo '--------------------------------------------------------------------------------------------------------'
    ROOT_RESTORE_JOB_ID=$(aws backup start-restore-job --recovery-point-arn $SNAPSHOT_ARN_ROOT  --iam-role-arn arn:aws:iam::${ACCOUNT_ID}:role/tf-eu-west-2-hmpps-delius-${ENV_TYPE}-mis-mis-ec2-bkup-pri-iam  --resource-type EBS  --profile $profile --region $REGION --metadata  volumeId=${ROOT_VOLUME},availabilityZone=${INSTANCE_AZ} | jq -r .RestoreJobId)
    SECONDARY_RESTORE_JOB_ID=$(aws backup start-restore-job --recovery-point-arn $SNAPSHOT_ARN_SECONDARY  --iam-role-arn arn:aws:iam::${ACCOUNT_ID}:role/tf-eu-west-2-hmpps-delius-${ENV_TYPE}-mis-mis-ec2-bkup-pri-iam  --resource-type EBS  --profile $profile --region $REGION --metadata  volumeId=${SECONDARY_VOLUME},availabilityZone=${INSTANCE_AZ} | jq -r .RestoreJobId)

    if [[ -z "$ROOT_RESTORE_JOB_ID" ]] || [[ -z "$SECONDARY_RESTORE_JOB_ID" ]]; then
        echo "Failed to obtain restore job ID ...exiting"
        exit 1
    fi

    #Get root restored volume id
    echo '--------------------------------------------------------------------------------------------------------'
    echo "Restoring root device /dev/sda1 for $instance_id"
    echo '--------------------------------------------------------------------------------------------------------'

    ROOT_RESTORE_STATUS=$(aws backup describe-restore-job --restore-job-id $ROOT_RESTORE_JOB_ID --profile $profile --region $REGION | jq -r .Status)
    while [[ $ROOT_RESTORE_STATUS == "RUNNING" ]]
        do
            echo '--------------------------------------------------------------------------------------------------------'
            echo "Restore Job: $ROOT_RESTORE_JOB_ID is not in COMPLETED state ...retrying"
            echo '--------------------------------------------------------------------------------------------------------'
            sleep 30
            ROOT_RESTORE_STATUS=$(aws backup describe-restore-job --restore-job-id $ROOT_RESTORE_JOB_ID --profile $profile --region $REGION | jq -r .Status)
            echo '--------------------------------------------------------------------------------------------------------'
            echo "Restore Job: $ROOT_RESTORE_JOB_ID is in state: $ROOT_RESTORE_STATUS"
            echo '--------------------------------------------------------------------------------------------------------'
            if [[ "$ROOT_RESTORE_STATUS" == "COMPLETED" ]]; then
                break
            fi
        done
     ROOT_RESTORED_VOLUME_ID=$(aws backup describe-restore-job --restore-job-id $ROOT_RESTORE_JOB_ID --profile $profile --region eu-west-2 | jq -r .CreatedResourceArn | cut -f2 -d/)

    #Get secondary restored volume id
    echo '--------------------------------------------------------------------------------------------------------'
    echo "Restoring secondary device /dev/xvdb for $instance_id"
    echo '--------------------------------------------------------------------------------------------------------'

    SECONDARY_RESTORE_STATUS=$(aws backup describe-restore-job --restore-job-id $SECONDARY_RESTORE_JOB_ID --profile $profile --region $REGION | jq -r .Status)
    while [[ $SECONDARY_RESTORE_STATUS == "RUNNING" ]]
        do
            echo '--------------------------------------------------------------------------------------------------------'
            echo "Restore Job: $SECONDARY_RESTORE_JOB_ID is not in COMPLETED state ...retrying"
            echo '--------------------------------------------------------------------------------------------------------'
            sleep 30
            SECONDARY_RESTORE_STATUS=$(aws backup describe-restore-job --restore-job-id $SECONDARY_RESTORE_JOB_ID --profile $profile --region $REGION | jq -r .Status)
            echo '--------------------------------------------------------------------------------------------------------'
            echo "Restore Job: $SECONDARY_RESTORE_JOB_ID is in state: $SECONDARY_RESTORE_STATUS"
            echo '--------------------------------------------------------------------------------------------------------'
            if [[ "$SECONDARY_RESTORE_STATUS" == "COMPLETED" ]]; then
                break
            fi
        done
    SECONDARY_RESTORED_VOLUME_ID=$(aws backup describe-restore-job --restore-job-id $SECONDARY_RESTORE_JOB_ID --profile $profile --region $REGION | jq -r .CreatedResourceArn | cut -f2 -d/)
    detach_old_volumes
    attach_new_volumes
done
}



enable_delete_on_term ()
{

#Create EBS.JSON FILE
cat << EOF > ebs.json
  [
     {
        "DeviceName":"/dev/sda1",
        "Ebs":{
           "DeleteOnTermination":true
        }
     }
  ]
EOF

IFS=$'\n';for instance in $INSTANCE_IDS; do
  instance_id=$(echo "$instance" | awk '{ print $1 }')

  echo '--------------------------------------------------------------------------------------------------------'
  echo "Setting DeleteOnTermination to true on $instance_id root volume"
  echo '--------------------------------------------------------------------------------------------------------'
  echo "aws ec2 modify-instance-attribute --instance-id ${instance_id} --block-device-mappings file://ebs.json --profile $profile  --region $REGION"
  sleep 10
  aws ec2 modify-instance-attribute --instance-id ${instance_id} --block-device-mappings file://ebs.json --profile $profile  --region $REGION || exit $?
done
rm -rf ebs.json
}


start_instances ()
{
  IFS=$'\n';for instance in $INSTANCE_IDS; do
    instance_id=$(echo "$instance" | awk '{ print $1 }')
    echo '--------------------------------------------------------------------------------------------------------'
    echo "Starting instance_id $instance_id"
    echo '--------------------------------------------------------------------------------------------------------'
    echo "aws ec2 start-instances --instance-ids $instance_id --profile $profile --region ${REGION}"
    sleep 10
    aws ec2 start-instances --instance-ids $instance_id --profile $profile --region ${REGION} || exit $?
  done
}

##MAIN
set_account_id
authenticate
get_host_list $HOST_TYPE
stop_instances
restore_snapshots
enable_delete_on_term
start_instances
rm ${HOME}/.aws/credentials
