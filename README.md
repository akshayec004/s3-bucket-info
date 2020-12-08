# s3-bucket-info
## Script Info
cf-s3-iam-stack.yaml  - Cloudformation stack to create 3 S3 buckets, IAM user and IAM Policy with read and write permissions to these buckets

s3-bucket-info.sh - Shell script to list out all the buckets and get bucket info - Creation date, total objects, total size, most recent file and S3 cost. 

### Steps to run the CF stack
* In order to run the CF stack from AWS CLI, we need to create an IAM user with below AWS managed policies 
  - IAMFullAccess
  - AWSCloudFormationFullAccess
* Set the AWS Access Key ID  and AWS Secret Access Key by running below command
  - aws configure
* Then, to deploy the CF stack via CLI, run the below command.
  - aws cloudformation deploy --template-file cf-s3-iam-stack.yaml --stack-name <Stack-Name> --parameter-overrides UserName=<IAM username> --capabilities CAPABILITY_NAMED_IAM
* All the S3 buckets created are prefixed with the stack name <Stack-Name>
* To view the bucket names and user access and secret keys, run the below command
  - aws cloudformation describe-stacks --stack-name s3-test
* Upload objects to the newly created buckets.
* Set the keys again with the keys of the IAM user created.
* Run the shell script s3-bucket-info.sh to get the bucket and object information.
* In order to run the script for the buckets owned by the company, first we need to set the keys that has read access for the buckets.

### Enhancements
* Creation of the CF stack can be automated using Jenkins or Codepipeline
* The shell script can be enhanced to get object level info.
