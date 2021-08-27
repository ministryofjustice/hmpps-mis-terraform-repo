#!/usr/bin/env bash

TASK=$1

add_fixed_response_rule ()
{
  LB_ARN=$(aws elbv2 describe-load-balancers --names ${LB_NAME} --region ${REGION} | jq -r .LoadBalancers[0].LoadBalancerArn)
  LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn ${LB_ARN}  --region ${REGION} --output text | grep LISTENERS | grep 443 | awk '{ print $2 }')
#Create conditions-host.json file
cat << EOF > conditions-host.json
[
  {
      "Field": "path-pattern",
      "PathPatternConfig": {
          "Values": ["/*"]
      }
  }
]
EOF

#Create actions-fixed-response.json file
cat << EOF > actions-fixed-response.json
[
    {
        "Type": "fixed-response",
        "FixedResponseConfig": {
            "MessageBody": "Attention: Ndelius MIS is unavailable between ${STOP_TIME} and ${RESUME_TIME} \n${MAINTENANCE_TASK} is in progress \nPlease try again later",
            "StatusCode": "200",
            "ContentType": "text/plain"
        }
    }
]
EOF

  echo "Adding fixed-response rule on Loadbalancer: ${LB_NAME} Account_ID: ${ACCOUNT_ID}"
  aws elbv2 create-rule --listener-arn $LISTENER_ARN --priority 1 --conditions file://conditions-host.json --actions file://actions-fixed-response.json --region ${REGION} || exit 1

}

remove_fixed_response_rule ()
{
  LB_ARN=$(aws elbv2 describe-load-balancers --names ${LB_NAME} --region ${REGION} | jq -r .LoadBalancers[0].LoadBalancerArn)
  LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn ${LB_ARN}  --region ${REGION} --output text | grep LISTENERS | grep 443 | awk '{ print $2 }')
  FIXED_RESPONSE_RULE_ARN=$(aws elbv2 describe-rules --listener-arn $LISTENER_ARN --region ${REGION} --output text | grep RULES | grep False | awk '{ print $4 }')
  echo "Removing fixed-response rule: ${FIXED_RESPONSE_RULE_ARN} on Loadbalancer: ${LB_NAME} Account_ID: ${ACCOUNT_ID}"
  aws elbv2 delete-rule --rule-arn $FIXED_RESPONSE_RULE_ARN --region ${REGION} || exit 1
}

usage ()
{
  echo '--------------------------------------------------------------------------------------------------------'
  echo "Usage $0 TASK"
  echo "TASK: stop | resume"
  echo '--------------------------------------------------------------------------------------------------------'
  exit 1
}

#Check supplied args
if [[ -z "${TASK}" ]]; then
    usage
fi

#Main
case "${TASK}" in
    stop) add_fixed_response_rule
               ;;
    resume) remove_fixed_response_rule
               ;;
    *) echo "${TASK} is not a valid argument for TASK. Use stop or resume"
       exit 1
               ;;
esac
