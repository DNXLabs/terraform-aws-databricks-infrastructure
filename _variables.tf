variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default = "Terraform"
}
variable "notebook_filename" {
  description = "The notebook's filename."
  type        = string
  default = "modules/terraform-aws-databricks/assets/notebook-getting-started.py"
  
}
variable "notebook_language" {
  description = "The language of the notebook."
  type        = string
  default = "PYTHON"
  
}

variable "job_name" {
  description = "A name for the job."
  type        = string
  default = "My Job"
}

variable "cluster_name" {
  description = "A name for the cluster."
  type        = string
  default = "DNXLabs-terraform-databricks"
}

variable "cluster_autotermination_minutes" {
  description = "How many minutes before automatically terminating due to inactivity."
  type        = number
  default = 60
}

variable "cluster_num_workers" {
  description = "The number of workers."
  type        = number
  default = 1
}

variable "resources_prefix" {
  description = "Databricks root bucket prefix" 
  type = string
  default = "everlight-poc"
}
variable "tags" {
  type = map
  description = "AWS tags"
  default = {}
}
variable "databricks_account_id" {
  type = string
  description = "Databticks account id"
  default = ""
}

variable "databricks_host" {
  type = string
  description = "Databticks host"
  default = ""
}
variable "cidr_block" {
  type = string
  description = "CIDR range for the workspace VPC"
  default = "10.184.0.0/16"
}
variable "region" {
  type = string
  description = "AWS Region"
  default = "ap-southeast-2"
}

variable "aws_account_id" {}

variable "databricks_users" {
  description = <<EOT
  List of Databricks users to be added at account-level for Unity Catalog.
  Enter with square brackets and double quotes
  e.g ["first.last@domain.com", "second.last@domain.com"]
  EOT
  type        = list(string)
}

variable "databricks_metastore_admins" {
  description = <<EOT
  List of Admins to be added at account-level for Unity Catalog.
  Enter with square brackets and double quotes
  e.g ["first.admin@domain.com", "second.admin@domain.com"]
  EOT
  type        = list(string)
}

variable "unity_admin_group" {
  description = "Name of the admin group. This group will be set as the owner of the Unity Catalog metastore"
  type        = string
  default = "Admin"
}

variable "metastore_bucket" {
  description = "Existing metastore bucket"
  type = string
}
variable "metastore_id" {
  description = "ID of existing metastore"
  type = string
  default = ""
  
}
