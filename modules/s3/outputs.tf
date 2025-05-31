output "bronze_name" {
  value = aws_s3_bucket.bronze.bucket
}
output "bronze_arn" {
  value = aws_s3_bucket.bronze.arn
}
output "bronze_id" {
  value = aws_s3_bucket.bronze.id
}

output "silver_name" {
  value = aws_s3_bucket.silver.bucket
}
output "silver_arn" {
  value = aws_s3_bucket.silver.arn
}
output "silver_id" {
  value = aws_s3_bucket.silver.id
}