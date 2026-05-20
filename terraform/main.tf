# =====================================================================
# Main Terraform Configuration for MeowMetrics
# Provisioning S3 Staging Storage & Snowflake Data Warehouse Objects
# =====================================================================

# 1. AWS STORAGE RESOURCES
resource "aws_s3_bucket" "lakehouse_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "MeowMetrics Lakehouse Storage"
    Project     = "MeowMetrics"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.lakehouse_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. SNOWFLAKE DATABASE WAREHOUSE & ROLES
resource "snowflake_warehouse" "warehouse" {
  name           = "MEOW_WH"
  warehouse_size = var.snowflake_warehouse_size
  auto_suspend   = 60
  auto_resume    = true
  
  initially_suspended = true
  
  comment = "Virtual warehouse for loading and transformation pipelines"
}

resource "snowflake_database" "database" {
  name    = var.snowflake_database_name
  comment = "Primary database containing MeowMetrics staging and analytics tables"
}

# 3. SCHEMAS INSIDE SNOWFLAKE DATABASE
resource "snowflake_schema" "raw_stage" {
  database = snowflake_database.database.name
  name     = "RAW_STAGE"
  comment  = "Schema for external tables, stages, and raw ingestion files"
}

resource "snowflake_schema" "analytics" {
  database = snowflake_database.database.name
  name     = "ANALYTICS"
  comment  = "Schema for modeling gold marts, dimensions, and facts via dbt"
}

# 4. CUSTOM ACCESS CONTROL RULES
resource "snowflake_role" "dbt_role" {
  name    = "MEOW_DBT_ROLE"
  comment = "Service role assigned to dbt jobs to read raw and write gold schemas"
}

# Grant privileges to the custom role
resource "snowflake_database_grant" "db_grant" {
  database_name = snowflake_database.database.name
  privilege     = "USAGE"
  roles         = [snowflake_role.dbt_role.name]
}

resource "snowflake_schema_grant" "raw_grant" {
  database_name = snowflake_database.database.name
  schema_name   = snowflake_schema.raw_stage.name
  privilege     = "USAGE"
  roles         = [snowflake_role.dbt_role.name]
}

resource "snowflake_schema_grant" "analytics_grant" {
  database_name = snowflake_database.database.name
  schema_name   = snowflake_schema.analytics.name
  privilege     = "ALL PRIVILEGES"
  roles         = [snowflake_role.dbt_role.name]
}
