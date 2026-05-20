terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.70.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Snowflake provider configuration
# Credentials should be set via environment variables in production:
# SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ACCOUNT, etc.
provider "snowflake" {
  role = "SYSADMIN"
}
