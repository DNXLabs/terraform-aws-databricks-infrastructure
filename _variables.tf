variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default = "Terraform"
}
variable "notebook_filename" {
  description = "The notebook's filename."
  type        = string
  default = "assets/notebook-getting-started.py"
  
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
  default = "DNSLabs-terraform-databricks"
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
  default = ""
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
