import json
import boto3
import time
client = boto3.client('ec2')

def lambda_handler(event, context):
   instance_type = event['ec2type']
   # insert code to determine instance to be resized
   client = boto3.client('ec2')

   #custom_filter = [
   #   {
   #      'Name':'tag:enable_resizing_schedule', 
   #      'Values': ['true']
   #   }
   #]
    
response = client.describe_instances(Filters=custom_filter)
    instance_id = 'i-00956563a4fcb4acc'
    
    # Stop the instance
    client.stop_instances(InstanceIds=[instance_id])
    waiter=client.get_waiter('instance_stopped')
    waiter.wait(InstanceIds=[instance_id])
    
    # Change the instance type
    client.modify_instance_attribute(InstanceId=instance_id, Attribute='instanceType', Value=instance_type)
    
    # Start the instance
    client.start_instances(InstanceIds=[instance_id])
  
    return {
        'statusCode': 200,
        'body': json.dumps('Resizing has been completed')
    }