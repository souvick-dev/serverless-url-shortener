import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('serverless-url-shortener-dev')

def lambda_handler(event, context):
    try:
        short_code = event['pathParameters']['shortCode']
        
        response = table.get_item(
            Key={'shortCode': short_code}
        )
        
        item = response.get('Item')
        
        if not item:
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'URL not found'})
            }
        
        # Update click count
        table.update_item(
            Key={'shortCode': short_code},
            UpdateExpression='SET clickCount = clickCount + :val',
            ExpressionAttributeValues={':val': 1}
        )
        
        return {
            'statusCode': 301,
            'headers': {
                'Location': item['originalUrl'],
                'Access-Control-Allow-Origin': '*'
            },
            'body': ''
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }