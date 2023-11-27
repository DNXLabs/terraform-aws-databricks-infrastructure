terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      configuration_aliases = [databricks.mws, databricks.workspace]
    }
    aws = {
      source = "hashicorp/aws"
      version = ">= 0.13.0"

    }
  }
}
