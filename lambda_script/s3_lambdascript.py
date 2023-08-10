import json
import boto3

def lambda_handler(event, context):
    # Extract information from the S3 event
    s3_event = event['Records'][0]['s3']
    bucket_name = s3_event['bucket']['name']
    object_key = s3_event['object']['key']

    # Create an SNS client
    sns_client = boto3.client('sns')

    # Define the SNS topic ARN
    sns_topic_arn = 'arn:aws:sns:ap-south-1:172165467462:s3-sns'

    # Construct the email notification message
    message = f"An object was uploaded to S3 bucket: {bucket_name}\nObject Key: {object_key}"

    # Publish the message to the SNS topic
    sns_client.publish(
        TopicArn=sns_topic_arn,
        Message=message,
        Subject="S3 Object Upload Notification"
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Email notification sent successfully')
    }
