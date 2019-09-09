#!/bin/bash

# Error handler function
exit_on_error() {
  exit_code=$1
  last_command=${@:2}
  if [ $exit_code -ne 0 ]; then
      >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
      exit ${exit_code}
  fi
}


###set environment
set_env_stage ()
{
  env_config_dir="/home/tools/data/env_configs"

  echo "Output -> clone configs stage"
  rm -rf ${env_config_dir}
  echo "Output ---> Cloning branch: master"
  git clone https://github.com/ministryofjustice/hmpps-env-configs.git ${env_config_dir}
  exit_on_error $? !!

  echo "Output -> environment stage"

  echo "Output -> environment_type set to: ${TG_ENVIRONMENT_TYPE}"

  source ${env_config_dir}/${TG_ENVIRONMENT_TYPE}/${TG_ENVIRONMENT_TYPE}.properties
  exit_on_error $? !!

  echo "Using IAM role: ${TERRAGRUNT_IAM_ROLE}"

  export OUTPUT_FILE="${env_config_dir}/temp_creds"

  export temp_role=$(aws sts assume-role --role-arn ${TERRAGRUNT_IAM_ROLE} --role-session-name testing --duration-seconds 3600 )
}

# get creds
get_creds_aws () {
  sh scripts/get_creds.sh
  source ${OUTPUT_FILE}
  exit_on_error $? !!
  rm -rf ${OUTPUT_FILE}
  exit_on_error $? !!
}

####Perform efs backup
efs_backup () {
case ${JOB_TYPE} in
  efs-backup)
    echo "Running EFS backup"
	mkdir $BACKUP_DIR
    ping fs-b04be441.efs.eu-west-2.amazonaws.com
    ;;
  *)
    echo "${JOB_TYPE} argument is not a valid argument. efs-backup"
  ;;
esac
}


########MAIN
#Vars
BACKUP_DIR="/home/tools/data/backup"
JOB_TYPE=$1
TG_ENVIRONMENT_TYPE=${2}
set_env_stage
NEXTCLOUD_BACKUP_BUCKET="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-backups"
PREFIX_DATE=$(date +%F)


##Check args provided
if [ -z "${JOB_TYPE}" ]
then
    echo "JOB_TYPE argument not supplied."
    exit 1
elif [ -z "${TG_ENVIRONMENT_TYPE}"]
then
    echo "TG_ENVIRONMENT_TYPE argument not supplied."
    exit 1
fi

efs_backup
