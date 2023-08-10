# AWS Project with Shell Script

This project demonstrates the use of a shell script to automate the creation of AWS resources. The script sets up an IAM role with attached policies, creates an S3 bucket, a Lambda function, and an SNS topic.

# Benefits of this project

  1. saves the time for Devops Engineer as well as Developer to creates resources

  2. if there are 40 aws accounts which require the same setup ,you can do that by just running this script

  3. easy to identify when was the object created and who created it

  4. mainly it avoids manual mistakes because its already scripted 
     
# Goal of this project

***********to automate the resources creation in any iam user account and send email notification when new object is uploaded to s3 bucket************

## Prerequisites

- AWS CLI installed and configured with necessary permissions.
- Shell environment (Linux/macOS) to run the script.

## Usage

1. make sure you have aws cli installed by typing the command 'aws'

2. Clone this repository to your local machine

3. Change the environment variables in 's3_notification_trigger.sh' ,update it with your aws account id,region etc

4. Grant the permission for s3_notification_trigger.sh file

5. run the script

6. got to your mail and confirm the subscription

7. now you can upload some random files into the bucket , ***** you can see the MAGIC in your mail saying that a new object is created ******

