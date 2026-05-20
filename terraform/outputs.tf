output "s3_bucket_arn" {
  value       = aws_s3_bucket.lakehouse_bucket.arn
  description = "ARN of the AWS S3 Lakehouse Bucket"
}

output "snowflake_warehouse_name" {
  value       = snowflake_warehouse.warehouse.name
  description = "Name of the provisioned Snowflake compute warehouse"
}

output "snowflake_database_name" {
  value       = snowflake_database.database.name
  description = "Name of the provisioned Snowflake database"
}
