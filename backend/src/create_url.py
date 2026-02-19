import json
import boto3
import random
import string
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('serverless-url-shortener-dev')

def generate_short_code(length=6):
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for _ in range(length))

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        original_url = body['originalUrl']
        user_id = body.get('userId', 'anonymous')
        
        short_code = generate_short_code()
        
        item = {
            'shortCode': short_code,
            'originalUrl': original_url,
            'userId': user_id,
            'createdAt': datetime.now().isoformat(),
            'clickCount': 0
        }
        
        table.put_item(Item=item)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'shortCode': short_code,
                'originalUrl': original_url,
                'message': 'URL created successfully'
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }