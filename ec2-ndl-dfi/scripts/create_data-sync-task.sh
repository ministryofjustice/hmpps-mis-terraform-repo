#!/bin/bash
REGION=$1
SOURCE_LOCATION_ARN=$2
CLOUDWATCH_LOG_ARN=$3
NAME=$4
FSX_SG_ARN=$5
USER_PARAM=$6
PASS_PARAM=$7
FSX_DOMAIN=$8
OPTIONS=VerifyMode="NONE",OverwriteMode="ALWAYS",Atime="BEST_EFFORT",Mtime="PRESERVE",Uid="NONE",Gid="NONE",PreserveDeletedFiles="REMOVE",PreserveDevices="NONE",PosixPermissions="NONE",TaskQueueing="ENABLED",LogLevel="TRANSFER"

#Create Destination Location    #Unable to consume FSX outputs as it is written in TF13
FSX_USER=$(aws ssm get-parameters --names $USER_PARAM --region $REGION --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')                      || exit $?
FSX_PASS=$(aws ssm get-parameters --with-decryption --names $PASS_PARAM --region $REGION --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')    || exit $?
FSX_ARN=$(aws fsx describe-file-systems | jq -r .FileSystems[0].ResourceARN)  || exit $?
DESTINATION_LOCATION_ARN=$(aws datasync create-location-fsx-windows --fsx-filesystem-arn "${FSX_ARN}" --security-group-arns "${FSX_SG_ARN}" --user "${FSX_USER}" --password "${FSX_PASS}" --subdirectory "dfinterventions/dfi"   --domain "${FSX_DOMAIN}" --tags "Key=Name,Value=$NAME" --region "${REGION}" | jq -r .LocationArn) || exit $?

#Create datasync Task
aws datasync create-task  --source-location-arn ${SOURCE_LOCATION_ARN} --destination-location-arn  ${DESTINATION_LOCATION_ARN} --cloud-watch-log-group-arn ${CLOUDWATCH_LOG_ARN}  --name ${NAME} --options ${OPTIONS}  --region ${REGION} && echo Success || exit $?
