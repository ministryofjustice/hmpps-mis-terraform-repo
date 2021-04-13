import json
import boto3
import os

print('Loading function')

s3 = boto3.client('s3')
client = boto3.client('codebuild')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    PROJECT_NAME = os.environ.get("CODEBUILD_PROJECT_NAME")

    try:
        print(f'Invoking {PROJECT_NAME}')
        response = client.start_build(projectName=PROJECT_NAME)
    except Exception as e:
        print(e)
        print('Error processing request')
        raise e
