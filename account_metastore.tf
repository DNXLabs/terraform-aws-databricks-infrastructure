locals {
  root_bucket_key = "rootbucket"
}
resource "databricks_metastore" "this" {
  provider      = databricks.mws
  name          = "metastore_aws_ap_southeast_2"
  storage_root  = "s3://${aws_s3_bucket.storage_buckets[local.root_bucket_key].id}/metastore"
  region        = var.region
  force_destroy = true
}

resource "databricks_metastore_data_access" "this" {
  provider     = databricks.mws
  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.cross_account_role.name
  aws_iam_role {
    role_arn = aws_iam_role.cross_account_role.arn
  }
  is_default = true
}
