def lambda_handler(event, context):
   return {
       'statusCode': 200,
       'body': '{"message": "Hello from Backend Lambda!"}',
       'headers': {
           'Content-Type': 'application/json'
       }
   }