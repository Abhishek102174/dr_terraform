def lambda_handler(event, context):
   # Simple authorizer - in real implementation, validate JWT or other tokens
   token = event.get('authorizationToken', '').lower()
   # For demo purposes: "allow" grants access, anything else denies
   effect = 'Allow' if token == 'allow' else 'Deny'
   return {
       'principalId': 'user',
       'policyDocument': {
           'Version': '2012-10-17',
           'Statement': [{
               'Action': 'execute-api:Invoke',
               'Effect': effect,
               'Resource': event['methodArn']
           }]
       }
   }