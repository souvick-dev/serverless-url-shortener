import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('serverless-url-shortener-dev')

def lambda_handler(event, context):
    try:
        user_id = event['queryStringParameters'].get('userId', 'anonymous')
        
        response = table.query(
            IndexName='UserIdIndex',
            KeyConditionExpression='userId = :uid',
            ExpressionAttributeValues={':uid': user_id}
        )
        
        items = response.get('Items', [])
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'urls': items,
                'count': len(items)
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }