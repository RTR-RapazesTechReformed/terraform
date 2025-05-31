resource "random_id" "lambda_prefix" {
  byte_length = 4
}

locals {
  lambda_function_name_etl = "${random_id.lambda_prefix.hex}-etl-poc"
  lambda_function_name_sns = "${random_id.lambda_prefix.hex}-sns-poc"
}

resource "aws_lambda_function" "processar_csv" {
  function_name    = local.lambda_function_name_etl
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.9"
  role             = var.role_arn_aws #colocar o arn da role de Lab
  filename         = "${path.module}/lambda_etl/lambda_handler.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_etl/lambda_handler.zip")
  timeout          = 90

  # camada do pandas
  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python39:28"
  ]

  environment {
    variables = {
      BUCKET_DESTINO = var.silver_name
    }
  }

}

# Permitir que o S3 invoque a Lambda
resource "aws_lambda_permission" "allow_s3_etl" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processar_csv.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bronze_arn
}

# Trigger: evento no S3 aciona o Lambda
resource "aws_s3_bucket_notification" "bucket_trigger_etl" {
  bucket = var.bronze_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.processar_csv.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_etl]
}

resource "aws_lambda_function" "mandar_sns" {
  function_name    = local.lambda_function_name_sns
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.9"
  role             = var.role_arn_aws #colocar o arn da role de Lab
  filename         = "${path.module}/lambda_sns/lambda_handler.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_sns/lambda_handler.zip")
  timeout          = 90

  environment {
    variables = {
      SNS_TOPIC_ARN = var.topic_arn
      EMAIL_LIST    = jsonencode(var.email_list)
    }
  }

}

resource "aws_lambda_permission" "allow_s3_sns" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mandar_sns.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.silver_arn
}

resource "aws_s3_bucket_notification" "bucket_trigger_sns" {
  bucket = var.silver_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.mandar_sns.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_sns]
}
