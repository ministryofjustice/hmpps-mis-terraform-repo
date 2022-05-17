#!/usr/bin/env bash

ENV_TYPE=$1
HOST_TYPE=$2
HOST_SUFFIX=$3
profile=backup_profile

if [[ -z $ENV_TYPE ]] || [[ -z $HOST_TYPE ]]; then
  echo '--------------------------------------------------------------------------------------------------------'
  echo "Usage $0 ENV_TYPE   HOST_TYPE"
  echo "ENV_TYPE: mis-dev | stage| pre-prod | prod"
  echo "HOST_TYPE: bws | bcs | bps| bws | dis"
  echo "Creates on demand backup of MIS Windows host EBS volumes"
  echo '--------------------------------------------------------------------------------------------------------'
  exit 1
fi

#Functions
set_account_id () {

case "${ENV_TYPE}" in
    mis-dev)   ACCOUNT_ID="479759138745"
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


get_host_list ()
{
    HOSTNAME=tf-${REGION}-hmpps-delius-${ENV_TYPE}-mis-ndl-${1}-${2}
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

  if [[ "$ENV_TYPE" == "mis-dev" ]]; then
      echo '--------------------------------------------------------------------------------------------------------'
      echo "Disabling auto-stop on $instance_id"
      echo '--------------------------------------------------------------------------------------------------------'
      echo "aws ec2 create-tags --resources $instance_id --tags Key=autostop-${ENV_TYPE},Value=False --profile $profile --region ${REGION}"
      sleep 10
      aws ec2 create-tags --resources $instance_id --tags Key=autostop-${ENV_TYPE},Value=False --profile $profile --region ${REGION} || exit $?
  fi

  echo '--------------------------------------------------------------------------------------------------------'
  echo "Stopping instance $instance_id"
  echo '--------------------------------------------------------------------------------------------------------'
  echo "aws ec2 stop-instances --instance-ids $instance_id --profile $profile --region ${REGION}"
  sleep 10
  aws ec2 stop-instances --instance-ids $instance_id --profile $profile --region ${REGION} || exit $?
  INSTANCE_STATUS=$(aws ec2 describe-instances --instance-ids $instance_id --profile $profile --region $REGION | jq -r '.Reservations[0].Instances[0].State.Name')
  echo "$instance_id is in state: $INSTANCE_STATUS"
  while [[ $INSTANCE_STATUS != "stopped" ]]
      do
          echo '--------------------------------------------------------------------------------------------------------'
          echo "Waiting for Instance: $instance_id  to be in stopped state ...retrying"
          echo '--------------------------------------------------------------------------------------------------------'
          sleep 30
          INSTANCE_STATUS=$(aws ec2 describe-instances --instance-ids $instance_id --profile $profile --region $REGION | jq -r '.Reservations[0].Instances[0].State.Name')
          echo '--------------------------------------------------------------------------------------------------------'
          echo "Instance: $instance_id is in state: $INSTANCE_STATUS"
          echo '--------------------------------------------------------------------------------------------------------'
          if [[ "$INSTANCE_STATUS" == "stopped" ]]; then
              echo "Instance: $instance_id is now in state stopped ...proceeding"
              break
          fi
      done
done
}

backup_snapshots ()
{
IFS=$'\n';for instance in $INSTANCE_IDS; do
  instance_id=$(echo "$instance" | awk '{ print $1 }')
    ROOT_VOLUME=$(aws ec2 describe-volumes      --filters Name=attachment.instance-id,Values=$instance_id  Name=attachment.device,Values=/dev/sda1 --profile $profile --region ${REGION} | jq -r .Volumes[0].VolumeId)
    SECONDARY_VOLUME=$(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$instance_id  Name=attachment.device,Values=/dev/xvdb --profile $profile --region ${REGION} | jq -r .Volumes[0].VolumeId)

    #Perform on demand snapshot
    echo '--------------------------------------------------------------------------------------------------------'
    echo "Backing up devices: /dev/sda1 & /dev/xvdb concurrently for $instance_id"
    echo '--------------------------------------------------------------------------------------------------------'
    ROOT_BACKUP_JOB_ID=$(aws backup start-backup-job --backup-vault-name delius-${ENV_TYPE}-${HOST_TYPE}-ec2-bkup-pri-vlt --resource-arn arn:aws:ec2:${REGION}:${ACCOUNT_ID}:volume/${ROOT_VOLUME}  --iam-role-arn arn:aws:iam::${ACCOUNT_ID}:role/tf-eu-west-2-hmpps-delius-${ENV_TYPE}-mis-mis-ec2-bkup-pri-iam  --lifecycle DeleteAfterDays=14 --profile $profile --region $REGION | jq -r .BackupJobId)
    SECONDARY_BACKUP_JOB_ID=$(aws backup start-backup-job --backup-vault-name delius-${ENV_TYPE}-${HOST_TYPE}-ec2-bkup-pri-vlt --resource-arn arn:aws:ec2:${REGION}:${ACCOUNT_ID}:volume/${SECONDARY_VOLUME}  --iam-role-arn arn:aws:iam::${ACCOUNT_ID}:role/tf-eu-west-2-hmpps-delius-${ENV_TYPE}-mis-mis-ec2-bkup-pri-iam  --lifecycle DeleteAfterDays=14 --profile $profile --region $REGION | jq -r .BackupJobId)

    if [[ -z "$ROOT_BACKUP_JOB_ID" ]] || [[ -z "$SECONDARY_BACKUP_JOB_ID" ]]; then
        echo "Failed to obtain restore job ID ...exiting"
        exit 1
    fi

    ROOT_BACKUP_JOB_STATUS=$(aws backup describe-backup-job   --backup-job-id $ROOT_BACKUP_JOB_ID      --profile $profile --region $REGION | jq -r .State)
    while [[ $ROOT_BACKUP_JOB_STATUS == "RUNNING" ]]
        do
            echo '--------------------------------------------------------------------------------------------------------'
            echo "Backup Job: $ROOT_BACKUP_JOB_ID for /dev/sda1 is not in COMPLETED state ...retrying"
            echo '--------------------------------------------------------------------------------------------------------'
            sleep 30
            ROOT_BACKUP_JOB_STATUS=$(aws backup describe-backup-job   --backup-job-id $ROOT_BACKUP_JOB_ID      --profile $profile --region $REGION | jq -r .State)
            echo '--------------------------------------------------------------------------------------------------------'
            echo "Backup Job: $ROOT_BACKUP_JOB_ID is in state: $ROOT_BACKUP_JOB_STATUS"
            echo '--------------------------------------------------------------------------------------------------------'
            if [[ "$ROOT_BACKUP_JOB_STATUS" == "COMPLETED" ]]; then
                echo "Backup for /dev/sda1 is completed"
                break
            fi
        done

        SECONDARY_BACKUP_JOB_STATUS=$(aws backup describe-backup-job   --backup-job-id $SECONDARY_BACKUP_JOB_ID --profile $profile --region $REGION | jq -r .State)
        while [[ $SECONDARY_BACKUP_JOB_STATUS == "RUNNING" ]]
            do
                echo '--------------------------------------------------------------------------------------------------------'
                echo "Backup Job: $SECONDARY_BACKUP_JOB_ID for /dev/xvdb is not in COMPLETED state ...retrying"
                echo '--------------------------------------------------------------------------------------------------------'
                sleep 30
                SECONDARY_BACKUP_JOB_STATUS=$(aws backup describe-backup-job   --backup-job-id $SECONDARY_BACKUP_JOB_ID --profile $profile --region $REGION | jq -r .State)
                echo '--------------------------------------------------------------------------------------------------------'
                echo "Backup Job: $SECONDARY_BACKUP_JOB_ID is in state: $SECONDARY_BACKUP_JOB_STATUS"
                echo '--------------------------------------------------------------------------------------------------------'
                if [[ "$SECONDARY_BACKUP_JOB_STATUS" == "COMPLETED" ]]; then
                    echo "Backup for /dev/xvdb is completed"
                    break
                fi
            done

done
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

    if [[ "$ENV_TYPE" == "mis-dev" ]]; then
        echo '--------------------------------------------------------------------------------------------------------'
        echo "Re-enabling auto-stop on $instance_id"
        echo '--------------------------------------------------------------------------------------------------------'
        echo "aws ec2 create-tags --resources $instance_id --tags Key=autostop-${ENV_TYPE},Value=True --profile $profile --region ${REGION}"
        sleep 10
        aws ec2 create-tags --resources $instance_id --tags Key=autostop-${ENV_TYPE},Value=True --profile $profile --region ${REGION} || exit $?
    fi
  done
}

set_account_id
authenticate
get_host_list $HOST_TYPE $HOST_SUFFIX
stop_instances
backup_snapshots
start_instances
