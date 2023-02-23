# Provider, where we deploy infrastructure
terraform {
  cloud {
    organization = "spacex-simulator"
    hostname = "app.terraform.io" # Optional; defaults to app.terraform.io

    workspaces {
      name = "foo" # TODO: We need to replace name by variable, the problem is that Terraform does not support vars here.
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }

  required_version = "~> 1.0"
}

// Create S3 Bucket for the Microservice
resource "aws_s3_bucket" "microservice_bucket" {
  bucket = "${var.PROJECT_NAME}-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.microservice_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.microservice_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "lambda_s3_object" {
  bucket = aws_s3_bucket.microservice_bucket.id

  key    = "${var.PROJECT_NAME}.zip"
  source = "${path.module}/build/distributions/${var.PROJECT_NAME}.zip"

  etag = filemd5("${path.module}/build/distributions/${var.PROJECT_NAME}.zip")
}

// Create a Lambda Function
resource "aws_lambda_function" "lambda_function" {
  function_name = var.PROJECT_NAME
  memory_size = 2048
  timeout = 30
  architectures = ["arm64"]

  s3_bucket = aws_s3_bucket.microservice_bucket.id
  s3_key    = aws_s3_object.lambda_s3_object.key

  runtime = "java11"
  handler = "com.spacexsimulator.foo.FooLambdaHandler::handleRequest"

  source_code_hash = filesha256("${path.module}/build/distributions/${var.PROJECT_NAME}.zip")

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      SPRING_PROFILES_ACTIVE = var.SPRING_PROFILES_ACTIVE
    }
  }
}

// Cloudwatch Configuration
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"

  retention_in_days = 30
}

// IAM Role Creation
resource "aws_iam_role" "lambda_exec" {
  name = "${var.PROJECT_NAME}_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

// IAM Role Attachment
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.PROJECT_NAME}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "apigateway_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lambda_function.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.apigateway_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_cloudwatch_log.arn
    format          = jsonencode({ "requestId" : "$context.requestId", "ip" : "$context.identity.sourceIp", "requestTime" : "$context.requestTime", "httpMethod" : "$context.httpMethod", "routeKey" : "$context.routeKey", "status" : "$context.status", "protocol" : "$context.protocol", "responseLength" : "$context.responseLength" })
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_cloudwatch_log" {
  name              = "/aws/apigateway/${var.PROJECT_NAME}-api"
  retention_in_days = 7
}

resource "aws_lambda_permission" "api_gw" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda_function.function_name
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_sqs_queue" "queue" {
  name                        = "${var.PROJECT_NAME}-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}