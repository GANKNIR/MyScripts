#Start a t2.micro ec2 instance using Amazon Linux 2 AMI (HVM), SSD Volume Type
provider "aws" {
  access_key = "xxxxxxxx"
  secret_key = "xxxxxxxx"
  region     = "us-east-1"
}

#You can run this script on your already running EC2 Instance

#You can externalize the AWS Credentials.

#Provider block is used to configure the provider. 

resource "aws_instance" "instance-1" {
  ami           = "ami-00b6a8a2bd28daf19"
  instance_type = "t2.micro"
}

