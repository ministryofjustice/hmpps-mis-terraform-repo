set +x

[ -z "${region}" ]           && region='eu-west-2'

# Fetch the latest list of running instances
# Returns a line for each instance, containing the tab-separated Instance ID and IP address
INSTANCES=$(aws ec2 describe-instances --output text --region "${region}" \
            --query 'Reservations[*].Instances[*].[InstanceId]' \
            --filters "Name=tag:Name,Values=tf-eu-west-2-hmpps-delius-prod-mis-ndl-*" \
                      'Name=instance-state-name,Values=running')

# echo "INSTANCES:
# $INSTANCES"

IFS=$'\n';for instance in $INSTANCES; do
  instance_id=$(echo "$instance" | awk '{ print $1 }')
  echo '--------------------------------------------------------------------------------------------------------'
  echo "updating instance_id '$instance_id' block-device-mappings for /dev/sda1 to DeleteOnTermination: true"
  echo '--------------------------------------------------------------------------------------------------------'
  aws --profile $1 ec2 modify-instance-attribute --instance-id ${instance_id} --block-device-mappings file://ebs.json --region ${region}
done
