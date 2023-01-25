import json
import botocore
import boto3
import os
import time

#define the connections
client = boto3.client('ec2')
    
# Stop the instance
def stop_ec2(instance):
    client.stop_instances(InstanceIds=[instance])
    waiter=client.get_waiter('instance_stopped')
    waiter.wait(InstanceIds=[instance])
    print ("Stopped ", instance)
    
# Change the instance type
def modify_ec2_type(instance, ec2_type):
    client.modify_instance_attribute(InstanceId=instance, Attribute='instanceType', Value=ec2_type)
    print(instance, " resized down to ", ec2_type)
    
# Start the instance
def start_ec2(instance):
    client.start_instances(InstanceIds=[instance])
    print("Started ", instance)
    
def handler(event, context):
    instance_type = event['ec2type']
    
    # Get instances id for ec2 instances with tag enable-ec2-resizing-schedule = true
    custom_filter = [
        {
            'Name': 'tag:enable-ec2-resizing-schedule', 
            'Values': ['true']
        }
    ]
    
    # Filter the instances satisfying the condition
    instance_ids = []
    response = client.describe_instances(Filters=custom_filter)
    instances_full_details = response['Reservations']
    
    # Stop instance, change attribute and start instance
    for instance_detail in instances_full_details:
        group_instances = instance_detail['Instances']

        for instance in group_instances:
            instance_id = instance['InstanceId']
            instance_ids.append(instance_id)
            
            stop_ec2(instance_id)
            modify_ec2_type(instance_id, instance_type)
            start_ec2(instance_id)
            
    return instance_ids
  
    return {
        'statusCode': 200,
        'body': json.dumps('Resizing has been completed')
    }