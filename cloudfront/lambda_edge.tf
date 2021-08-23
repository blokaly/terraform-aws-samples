
########################################################################
# Terraform resources for creating a Lambda@Edge
# for the terraform-aws-cloudfront-s3-website-lambda-edge
# Lambda@Edge nodejs10.x function to redirect
# fqdn.com/folder/index.html request to fqdn.com/folder
########################################################################

data "archive_file" "folder_index_redirect_zip" {
  type        = "zip"
  output_path = "${path.module}/folder_index_redirect.js.zip"
  source_file = "${path.module}/folder_index_redirect.js"
}

data "archive_file" "parse_client_ip_zip" {
  type        = "zip"
  output_path = "${path.module}/parse_client_ip.js.zip"
  source_file = "${path.module}/parse_client_ip.js"
}

resource "aws_iam_role_policy" "lambda_execution" {
  name_prefix = "lambda-execution-policy-"
  role        = aws_iam_role.lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_execution" {
  name_prefix        = "lambda-execution-role-"
  description        = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_function" "parse_client_ip" {
  description      = "Managed by Terraform"
  filename         = "${path.module}/parse_client_ip.js.zip"
  function_name    = "parse_client_ip"
  handler          = "parse_client_ip.handler"
  source_code_hash = data.archive_file.parse_client_ip_zip.output_base64sha256
  provider         = aws.aws_cloudfront
  publish          = true
  role             = aws_iam_role.lambda_execution.arn
  runtime          = "nodejs14.x"
}
