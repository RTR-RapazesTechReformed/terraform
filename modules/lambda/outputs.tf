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
