#!/bin/bash

JOB_TYPE=$1

if [ -z "${JOB_TYPE}" ]
then
    echo "JOB_TYPE argument not supplied."
    exit 1
fi

PREFIX_DATE=$(date +%F)
TG_REGION="eu-west-2"
DB_USER_PARAM="tf-eu-west-2-hmpps-delius-mis-test-nextcloud-db-user"
DB_PASS_PARAM="tf-eu-west-2-hmpps-delius-mis-test-nextcloud-db-password"
DB_HOST="nextcloud-db.delius-mis-test.internal"
NEXT_CLOUD_DB_NAME="nextcloud"

case ${JOB_TYPE} in
  db-backup)
    echo "Running db backup"
    BACKUP_DIR="/opt/local"
    SQL_FILE="${BACKUP_DIR}/nextcloud.sql"

    # delete sql file from nfs share
    rm -rf ${BACKUP_DIR}/*.sql

    # Get passsword from ssm
    DB_USER=$(aws ssm get-parameters --region ${TG_REGION} --names "${DB_USER_PARAM}" --query "Parameters[0]"."Value" --output text) && echo Success || exit $?
    DB_PASS=$(aws ssm get-parameters --with-decryption --names $DB_PASS_PARAM --region ${TG_REGION}  --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:') && echo Success || exit $?


    # Perform db backup
    mysqldump -u $DB_USER -p"$DB_PASS" -h $DB_HOST $NEXT_CLOUD_DB_NAME > $SQL_FILE && echo Success || exit $?

    # upload sql file
#    aws s3 cp --only-show-errors ${SQL_FILE} s3://${ALF_BACKUP_BUCKET}/${PREFIX_DATE}/ && echo Success || exit $?

    # delete sql file from nfs share
#    rm -rf ${SQL_FILE}

    ;;
  *)
    echo "${JOB_TYPE} argument is not a valid argument. db-backup - content-sync"
  ;;
esac

ls -ltrh $BACKUP_DIR
