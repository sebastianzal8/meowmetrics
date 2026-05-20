variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS region for MeowMetrics infrastructure"
}

variable "s3_bucket_name" {
  type        = string
  default     = "meowmetrics-lakehouse-prod"
  description = "Bucket storing smart collar raw landing and silver outputs"
}

variable "snowflake_database_name" {
  type        = string
  default     = "MEOW_DB"
  description = "Target database name in Snowflake"
}

variable "snowflake_warehouse_size" {
  type        = string
  default     = "XSMALL"
  description = "Initial sizing of the virtual warehouse"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment tag"
}
