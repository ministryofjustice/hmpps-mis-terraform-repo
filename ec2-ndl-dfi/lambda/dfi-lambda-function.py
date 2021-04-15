import json
import boto3
import os

print('Loading function')

client = boto3.client('codepipeline')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    PIPELINE_NAME = os.environ.get("CODE_PIPELINE_NAME")

    try:
        print(f'Invoking {PIPELINE_NAME}')
        response = client.start_pipeline_execution(name=PIPELINE_NAME)
    except Exception as e:
        print(e)
        print('Error processing request')
        raise e
