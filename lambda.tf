provider "aws" {
  region = "us-east-1"
}

#Resource type is aws lambda
resource "aws_lambda_function" "test-lambda" {
  function_name = "Test Lambda"
  #Name of the AWS Lambda function.

  s3_bucket = "test-lambda-build"
  s3_key    = "test-lambda.jar"

  #S3 bucket is the location of your packaged code 

  handler = "com.test.lambda.TestLambda::handleRequest"
  runtime = "java8"

  #Handler defines the method to call in the package and runtime is on which the code will run.

  role = "AWS_IAM_ROLE_ARN"
  #Role is the AWS IAM Role that Lambda will assume while running the code. 
}
