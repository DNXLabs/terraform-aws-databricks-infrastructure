resource "aws_s3_bucket" "storage_buckets" {
  bucket = "${var.resources_prefix}-rootbucket"
  bucket   = "${var.resources_prefix}-${each.value}"
  tags = merge(var.tags, {
    Name = "${var.resources_prefix}-${each.value}"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.storage_buckets[each.value].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "storage_buckets" {
  for_each                = var.buckets
  bucket                  = aws_s3_bucket.storage_buckets[each.value].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.storage_buckets]
}

data "databricks_aws_bucket_policy" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.storage_buckets[each.value].bucket
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  for_each   = var.buckets
  bucket     = aws_s3_bucket.storage_buckets[each.value].id
  policy     = data.databricks_aws_bucket_policy.this[each.value].json
  depends_on = [aws_s3_bucket_public_access_block.storage_buckets]

  lifecycle {
    ignore_changes = [ policy ]
  }
}

resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.storage_buckets[each.value].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "databricks_mws_storage_configurations" "this" {
  for_each                   = var.buckets
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.storage_buckets[each.value].bucket
  storage_configuration_name = "${var.resources_prefix}-${each.value}"
}

# resource "databricks_external_location" "this" {
#   provider        = databricks.workspace
#   for_each        = var.buckets
#   name            = "${each.value}-external-location"
#   url             = "s3://${aws_s3_bucket.storage_buckets[each.value].id}"
#   credential_name = databricks_storage_credential.this[0].id
#   comment         = "Managed by TF"
# }

resource "databricks_storage_credential" "this" {
  provider = databricks.workspace
  count    = length(var.buckets) > 0 ? 1 : 0
  name     = "external-storage-credential"
  aws_iam_role {
    role_arn = aws_iam_role.cross_account_role.arn
  }
  comment = "Managed by TF"
}

resource "databricks_grants" "external_creds" {
  provider = databricks.workspace
  storage_credential = databricks_storage_credential.this[0].id
  grant {
    principal  = data.databricks_current_user.me.user_name
    privileges = ["CREATE_EXTERNAL_LOCATION"]
  }
}
