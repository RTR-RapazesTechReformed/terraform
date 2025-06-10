output "lambda_function_name_etl" {
  value = aws_lambda_function.processar_csv.function_name
}

output "lambda_function_arn_etl" {
  value = aws_lambda_function.processar_csv.arn
}

output "lambda_function_name_sns" {
  value = aws_lambda_function.mandar_sns.function_name
}

output "lambda_function_arn_sns" {
  value = aws_lambda_function.mandar_sns.arn
}

output "lambda_function_arn_api" {
  value = aws_lambda_function.transformar-para-json.arn
}

output "allow_apigw_invoke" {
  value = aws_lambda_permission.allow_apigw_invoke
}
