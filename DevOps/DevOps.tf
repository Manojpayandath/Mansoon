#Configure aws account
provider "aws" {
shared_credentials_file = ""
region = "ca-central-1"
}

// S3 bucket for lambda
resource "aws_s3_bucket" "b1" {
  bucket = "my-tf-test1manoj-bucket"
  acl    = "private"
}
// S3 bucket for ftstae
resource "aws_s3_bucket" "b2" {
  bucket = "my-tf-test2manoj-bucket"
  acl    = "private"
}

// S3 bucket for staticfront
resource "aws_s3_bucket" "b3" {
  bucket = "my-tf-test3manoj-bucket"
  acl    = "public-read"
}

//S3 IAM Policy and Lambda Policy
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_role" "role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_policy" "s3_policy" {
  name = "PushToS3Policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.b1.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test_s3_attachment" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}

resource "aws_iam_policy" "lambda_policy" {
  name = "DeployLambdaPolicy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:PublishVersion",
        "lambda:UpdateAlias"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "test_lambda_attachment" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

// Lambda IAM role
resource "aws_iam_role" "lambda_role" {
  name = "AnagramFunctionRole"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
