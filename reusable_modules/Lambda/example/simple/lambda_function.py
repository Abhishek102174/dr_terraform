import os
import json
def lambda_handler(event, context):
   # Print environment variable 
   print(f"Environment: {os.environ['ENVIRONMENT']}")
   # Log the full event for debugging
   print("Received event:")
   print(json.dumps(event, indent=2))
   # Handle different trigger types
   if "Records" in event:
       record_count = len(event["Records"])
       print(f"Processing {record_count} records from event source")
       # Process S3 events
       if "s3" in event["Records"][0]:
           bucket = event["Records"][0]["s3"]["bucket"]["name"]
           key = event["Records"][0]["s3"]["object"]["key"]
           print(f"New S3 object: s3://{bucket}/{key}")
           return {"processed": record_count}
       # Process SQS events
       elif "eventSource" in event["Records"][0] and "aws:sqs" in event["Records"][0]["eventSource"]:
           print(f"Processed SQS messages")
           return {"processed": record_count}
   # Handle API Gateway requests
   if "httpMethod" in event:
       return {
           "statusCode": 200,
           "headers": {"Content-Type": "application/json"},
           "body": json.dumps({"message": "Success"})
       }
   # Default response for other triggers
   return {
       "status": "success",
       "event_type": str(type(event)),
       "environment": os.environ['ENVIRONMENT']
   }