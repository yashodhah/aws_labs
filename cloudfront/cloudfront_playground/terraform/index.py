def handler(event, context):
    """Simple Lambda handler for GET requests"""
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': '{"message": "Hello from CloudFront Playground!", "path": "' + event.get('rawPath', '/') + '"}'
    }
