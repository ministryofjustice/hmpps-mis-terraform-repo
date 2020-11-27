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
  env_config_dir="${CODEBUILD_SRC_DIR}/env_configs"

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

####Perform db backup
db_backup_restore () {

case "${JOB_TYPE}" in
    db-backup) echo "Running db backup"

               #get db creds
               echo "Getting DB details"
               get_creds_aws
               DB_USER=$(aws ssm get-parameters --region ${TG_REGION} --names "${DB_USER_PARAM}" --query "Parameters[0]"."Value" --output text) || exit 1
               DB_PASS=$(aws ssm get-parameters --with-decryption --names $DB_PASS_PARAM --region ${TG_REGION}  --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:') || exit 1
               DB_IDENTIFIER="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud"


               DB_HOST=$(aws rds describe-db-instances --region ${TG_REGION} --db-instance-identifier ${DB_IDENTIFIER} --query 'DBInstances[*].[Endpoint]' | grep Address | awk '{print $2}' | sed 's/"//g')
               exit_on_error $? !!

               mkdir $BACKUP_DIR

               # Perform db backup
               echo "Performing DB Backup"
               echo "mysqldump -u $DB_USER -h $DB_HOST $NEXT_CLOUD_DB_NAME > $SQL_FILE"
               mysqldump -u $DB_USER -p"$DB_PASS" -h $DB_HOST $NEXT_CLOUD_DB_NAME > $SQL_FILE
               exit_on_error $? !!
               echo "DB Backup complete"

               # upload sql file
               echo "Uploading Backup file to S3"
               get_creds_aws
               echo "aws s3 cp --only-show-errors ${SQL_FILE} s3://${NEXTCLOUD_BACKUP_BUCKET}/nextcloud_db_backups/${PREFIX_DATE}/ "
               aws s3 cp --only-show-errors ${SQL_FILE} s3://${NEXTCLOUD_BACKUP_BUCKET}/nextcloud_db_backups/${PREFIX_DATE}/ && echo Success || exit 1
               exit_on_error $? !!
               echo "Upload complete"

               # delete sql file
               rm -rf ${SQL_FILE}
               ;;
    db-restore)
               echo "Running Nextcloud DB Restore!"
               echo "File to restore: ${BACKUP_DATE}/nextcloud.sql"

               echo "Getting DB details"
               #get db creds
               get_creds_aws
               DB_USER=$(aws ssm get-parameters --region ${TG_REGION} --names "${DB_USER_PARAM}" --query "Parameters[0]"."Value" --output text) || exit 1
               DB_PASS=$(aws ssm get-parameters --with-decryption --names $DB_PASS_PARAM --region ${TG_REGION}  --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:') || exit 1
               DB_IDENTIFIER="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud"
               DB_HOST=$(aws rds describe-db-instances --region ${TG_REGION} --db-instance-identifier ${DB_IDENTIFIER} --query 'DBInstances[*].[Endpoint]' | grep Address | awk '{print $2}' | sed 's/"//g')
               exit_on_error $? !!

               echo "Creating Backup DIR --$BACKUP_DIR"
               mkdir $BACKUP_DIR

               #Download backup from s3
               echo "Downloading backup file from date ${BACKUP_DATE}"
               aws s3 cp --only-show-errors s3://${NEXTCLOUD_BACKUP_BUCKET}/nextcloud_db_backups/${BACKUP_DATE}/${NEXT_CLOUD_DB_NAME}.sql  ${BACKUP_DIR}   && echo "Backup file copied successfully" || exit 1

               ###Clean Database
               echo "Dropping Nextcloud DB"
               mysql -u $DB_USER -p"$DB_PASS" -h $DB_HOST  -e "DROP DATABASE ${NEXT_CLOUD_DB_NAME}"  && echo "DB Dropped successfully" || exit 1

               echo "Creating fresh Nextcloud DB"
               mysql -u $DB_USER -p"$DB_PASS" -h $DB_HOST  -e "CREATE DATABASE ${NEXT_CLOUD_DB_NAME}" && echo "DB creation Successfull" || exit 1

               #Restore db
               echo "Restoring Nextcloud DB from backup dated: ${BACKUP_DATE} "
               mysql -u $DB_USER -p"$DB_PASS" -h $DB_HOST $NEXT_CLOUD_DB_NAME < $SQL_FILE && echo "DB Restore Successfull" || exit 1

               # delete sql file
               rm -rf ${SQL_FILE}
               ;;
    *)         echo "${JOB_TYPE} argument is not a valid argument. db-backup | db-restore"
               ;;
esac
}


########MAIN
#Vars
BACKUP_DIR="/home/tools/data/backup"
JOB_TYPE=$1
TG_ENVIRONMENT_TYPE=${2}
BACKUP_DATE=${3}
set_env_stage


DB_USER_PARAM="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-db-user"
DB_PASS_PARAM="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-db-password"
NEXT_CLOUD_DB_NAME="nextcloud"
NEXTCLOUD_BACKUP_BUCKET="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}-nextcloud-backups"
PREFIX_DATE=$(date +%F)
SQL_FILE="${BACKUP_DIR}/nextcloud.sql"


##Check args provided
if [ -z "${JOB_TYPE}" ];
then
    echo "JOB_TYPE argument not supplied."
    exit 1
elif [ -z "${TG_ENVIRONMENT_TYPE}" ];
then
    echo "TG_ENVIRONMENT_TYPE argument not supplied."
    exit 1
elif [ ${JOB_TYPE} = "db-restore" ] && [ -z "$BACKUP_DATE" ];
then
    echo "JOB_TYPE : db-restore requires date parameter Format: YYYY-MM-DD"
    exit 1
fi

db_backup_restore
