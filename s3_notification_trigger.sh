set -x
###########################################################################

# Store the AWS account ID in a variable

aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text)

# printing the aws account id

echo "aws account id is $aws_account_id"

##########################################################################

#environment variable which can be changed


aws_region="ap-south-1"
bucket_name="madan-bucket"
lambda_func_name="s3-lambda-function"
role_name="s3-lambda-sns"
email_address="mk0007352@gmail.com"

#########################################################################

#creating IAM role

response_iam=$(aws iam create-role \
  --role-name $role_name \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  }'
)

#get the iam role ARN from the output


iamrole_arn=$(echo "$response_iam" | jq -r '.Role.Arn')

echo "iam role arn is: $iamrole_arn"

###########################################################################

#attaching policies to the iam role
aws iam attach-role-policy \
  --role-name $role_name \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-role-policy \
  --role-name $role_name \
  --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess

aws iam attach-role-policy \
  --role-name $role_name \
  --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess

##########################################################################

#creating bucket

bucket_output=$(aws s3api create-bucket --bucket $bucket_name --region $aws_region --create-bucket-configuration LocationConstraint=$aws_region)
echo "bucket creation output: $bucket_output"

##########################################################################

#creating sns topic

sns_topic=$(aws sns create-topic --name s3-sns)
sns_arn=$(echo "$sns_topic" | jq -r '.TopicArn')
echo "sns arn: $sns_arn"

#creating subscription

aws sns subscribe --topic-arn $sns_arn --protocol email --notification-endpoint $email_address


############################################################################


#zipping directory which has lambda script in it

zip -r lambda_script.zip ./lambda_script

sleep 5

#creating a lambda function

aws lambda create-function \
  --region $aws_region \
  --function-name $lambda_func_name \
  --runtime python3.8 \
  --handler lambda_script/s3_lambdascript.lambda_handler \
  --role $iamrole_arn \
  --zip-file fileb://./lambda_script.zip


#giving permission to s3 bucket to access the lambda function

aws lambda add-permission \
  --function-name "$lambda_func_name" \
  --statement-id "s3-lambda-sns" \
  --action "lambda:InvokeFunction" \
  --principal s3.amazonaws.com \
  --source-arn "arn:aws:s3:::$bucket_name"

#setting up eveny notification in s3 bucket

LambdaFunctionArn="arn:aws:lambda:$aws_region:$aws_account_id:function:$lambda_func_name"
aws s3api put-bucket-notification-configuration \
  --region "$aws_region" \
  --bucket "$bucket_name" \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [{
        "LambdaFunctionArn": "'"$LambdaFunctionArn"'",
        "Events": ["s3:ObjectCreated:*"]
    }]
}'





























