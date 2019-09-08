#!/bin/bash

set +e
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

####Perform db backup or restore
db_backup () {
case ${JOB_TYPE} in
  db-backup)
    echo "Running db backup"

    #get db creds
    get_creds_aws
    DB_USER=$(aws ssm get-parameters --region ${TG_REGION} --names "${DB_USER_PARAM}" --query "Parameters[0]"."Value" --output text) && echo Success || exit $?
    DB_PASS=$(aws ssm get-parameters --with-decryption --names $DB_PASS_PARAM --region ${TG_REGION}  --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:') && echo Success || exit $?
    DB_IDENTIFIER="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-db"
    DB_HOST=$(aws rds describe-db-instances --region ${TG_REGION} --db-instance-identifier ${DB_IDENTIFIER} \
                    --query 'DBInstances[*].[Endpoint]' | grep Address | awk '{print $2}' | sed 's/"//g') && echo Success || exit $?

    mkdir $BACKUP_DIR

    # Perform db backup
    mysqldump -u $DB_USER -p"$DB_PASS" -h $DB_HOST $NEXT_CLOUD_DB_NAME > $SQL_FILE && echo Success || exit $?

    # upload sql file
    get_creds_aws
    aws s3 cp --only-show-errors ${SQL_FILE} s3://${NEXTCLOUD_BACKUP_BUCKET}/nextcloud_db_backups/${PREFIX_DATE}/ && echo Success || exit $?

    # delete sql file
     rm -rf ${SQL_FILE}

    ;;
  *)
    echo "${JOB_TYPE} argument is not a valid argument. db-backup - content-sync"
  ;;
esac
}


########MAIN
#Vars
BACKUP_DIR="/home/tools/data/backup"
JOB_TYPE=$1
TG_ENVIRONMENT_TYPE=${2}
set_env_stage


DB_USER_PARAM="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-db-user"
DB_PASS_PARAM="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-db-password"
NEXT_CLOUD_DB_NAME="nextcloud"
NEXTCLOUD_BACKUP_BUCKET="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-backups"
PREFIX_DATE=$(date +%F)
BACKUP_DIR="/home/tools/data/backup"
SQL_FILE="${BACKUP_DIR}/nextcloud.sql"


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

db_backup
set -e
