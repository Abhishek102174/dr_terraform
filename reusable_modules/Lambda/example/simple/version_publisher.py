import boto3
import os
def lambda_handler(event, context):
   lambda_client = boto3.client('lambda')
   function_name = os.environ['TARGET_FUNCTION']
   # Publish new version
   response = lambda_client.publish_version(
       FunctionName=function_name
   )
   # Update alias to new version
   lambda_client.update_alias(
       FunctionName=function_name,
       Name='latest-version',
       FunctionVersion=response['Version']
   )
   return {
       'statusCode': 200,
       'body': f"Published version {response['Version']}"
   }