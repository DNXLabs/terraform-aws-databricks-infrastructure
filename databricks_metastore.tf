## S3 Bucket as Metastore data storage.

# resource "aws_s3_bucket" "metastore" {
#   bucket        = "${var.resources_prefix}-metastore"
#   force_destroy = true
#   tags = merge(var.tags, {
#     Name = "${var.resources_prefix}-metastore"
#   })
# }

# resource "aws_s3_bucket_versioning" "metastore_versioning" {
#   bucket = aws_s3_bucket.metastore.id
#   versioning_configuration {
#     status = "Disabled"
#   }
# }

# # ## IAM Role and Policies for Metastore access.

# data "aws_iam_policy_document" "passrole_for_uc" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
#       type        = "AWS"
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "sts:ExternalId"
#       values   = [var.databricks_account_id]
#     }
#   }
#   statement {
#     sid     = "ExplicitSelfRoleAssumption"
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
#     }
#     condition {
#       test     = "ArnLike"
#       variable = "aws:PrincipalArn"
#       values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.resources_prefix}-uc-access"]
#     }
#   }
# }


# resource "aws_iam_policy" "unity_metastore" {
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Action" : [
#           "s3:GetObject",
#           "s3:GetObjectVersion",
#           "s3:PutObject",
#           "s3:PutObjectAcl",
#           "s3:DeleteObject",
#           "s3:ListBucket",
#           "s3:GetBucketLocation",
#           "s3:GetLifecycleConfiguration",
#           "s3:PutLifecycleConfiguration"
#         ],
#         "Resource" : [
#           aws_s3_bucket.metastore.arn,
#           "${aws_s3_bucket.metastore.arn}/*"
#         ],
#         "Effect" : "Allow"
#       },
#       {
#         "Action" : [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey*"
#         ],
#         "Resource" : [
#           "arn:aws:kms:<KMS_KEY>" # TODO: FIX
#         ],
#         "Effect" : "Allow"
#       }
#     ]
#   })
#   tags = merge(var.tags, {
#     Name = "${var.resources_prefix}-unity-catalog IAM policy"
#   })
# }

# # // Required, in case https://docs.databricks.com/data/databricks-datasets.html are needed
# resource "aws_iam_policy" "sample_data" {
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "${var.resources_prefix}-databricks-sample-data"
#     Statement = [
#       {
#         "Action" : [
#           "s3:GetObject",
#           "s3:GetObjectVersion",
#           "s3:ListBucket",
#           "s3:GetBucketLocation"
#         ],
#         "Resource" : [
#           "arn:aws:s3:::databricks-datasets-oregon/*",
#           "arn:aws:s3:::databricks-datasets-oregon"

#         ],
#         "Effect" : "Allow"
#       }
#     ]
#   })
#   tags = merge(var.tags, {
#     Name = "${var.resources_prefix}-unity-catalog IAM policy"
#   })
# }

# resource "aws_iam_role" "metastore_data_access" {
#   name                = "${var.resources_prefix}-uc-access"
#   assume_role_policy  = data.aws_iam_policy_document.passrole_for_uc.json
#   managed_policy_arns = [aws_iam_policy.unity_metastore.arn, aws_iam_policy.sample_data.arn]
#   tags = merge(var.tags, {
#     Name = "${var.resources_prefix}-unity-catalog IAM role"
#   })
# }

# ## Metastore Users and Groups

# resource "databricks_user" "unity_users" {
#   provider  = databricks.mws
#   for_each  = toset(concat(var.databricks_users, var.databricks_metastore_admins))
#   user_name = each.key
#   force     = true
# }

# resource "databricks_group" "admin_group" {
#   provider     = databricks.mws
#   display_name = var.unity_admin_group
# }

# resource "databricks_group_member" "admin_group_member" {
#   provider  = databricks.mws
#   for_each  = toset(var.databricks_metastore_admins)
#   group_id  = databricks_group.admin_group.id
#   member_id = databricks_user.unity_users[each.value].id
# }

# resource "databricks_user_role" "metastore_admin" {
#   provider = databricks.mws
#   for_each = toset(var.databricks_metastore_admins)
#   user_id  = databricks_user.unity_users[each.value].id
#   role     = "account_admin"
# }

## Metastore unity Catalog

# resource "databricks_metastore" "this" {
#   provider      = databricks.mws
#   name          = "primary"
#   storage_root  = "s3://${var.metastore_bucket}/metastore"
#   owner         = var.unity_admin_group
#   region        = var.region
#   force_destroy = true
# }

# resource "databricks_metastore_data_access" "this" {
#   provider     = databricks.mws
#   metastore_id = databricks_metastore.this.id
#   name         = aws_iam_role.metastore_data_access.name
#   aws_iam_role {
#     role_arn = aws_iam_role.metastore_data_access.arn
#   }
#   is_default = true
# }


resource "databricks_metastore_assignment" "default_metastore" {
  provider             = databricks.mws
  workspace_id         = databricks_mws_workspaces.this.workspace_id
  metastore_id         = var.metastore_id
  default_catalog_name = "hive_metastore"
}

# ## Unity Catalog Objects

# resource "databricks_catalog" "sandbox" {
#   provider     = databricks.workspace
#   metastore_id = databricks_metastore.this.id
#   name         = "sandbox"
#   comment      = "this catalog is managed by terraform"
#   properties = {
#     purpose = "testing"
#   }
#   depends_on = [databricks_metastore_assignment.default_metastore]
# }

# resource "databricks_grants" "sandbox" {
#   provider = databricks.workspace
#   catalog  = databricks_catalog.sandbox.name
#   grant {
#     principal  = "Data Scientists"
#     privileges = ["USE_CATALOG", "CREATE"]
#   }
#   grant {
#     principal  = "Data Engineers"
#     privileges = ["USE_CATALOG"]
#   }
# }

# resource "databricks_schema" "things" {
#   provider     = databricks.workspace
#   catalog_name = databricks_catalog.sandbox.id
#   name         = "things"
#   comment      = "this database is managed by terraform"
#   properties = {
#     kind = "various"
#   }
# }

# resource "databricks_grants" "things" {
#   provider = databricks.workspace
#   schema   = databricks_schema.things.id
#   grant {
#     principal  = "Data Engineers"
#     privileges = ["USE_SCHEMA"]
#   }
# }

# ## External tables and credentials

# resource "aws_s3_bucket" "external" {
#   bucket = "${var.resources_prefix}-external"
#   // destroy all objects with bucket destroy
#   force_destroy = true
#   tags = merge(var.tags, {
#     Name = "${var.resources_prefix}-external"
#   })
# }

# resource "aws_s3_bucket_versioning" "external_versioning" {
#   bucket = aws_s3_bucket.external.id
#   versioning_configuration {
#     status = "Disabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "external" {
#   bucket             = aws_s3_bucket.external.id
#   ignore_public_acls = true
#   depends_on         = [aws_s3_bucket.external]
# }

# resource "aws_iam_policy" "external_data_access" {
#   // Terraform's "jsonencode" function converts a
#   // Terraform expression's result to valid JSON syntax.
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "${aws_s3_bucket.external.id}-access"
#     Statement = [
#       {
#         "Action" : [
#           "s3:GetObject",
#           "s3:GetObjectVersion",
#           "s3:PutObject",
#           "s3:PutObjectAcl",
#           "s3:DeleteObject",
#           "s3:ListBucket",
#           "s3:GetBucketLocation"
#         ],
#         "Resource" : [
#           aws_s3_bucket.external.arn,
#           "${aws_s3_bucket.external.arn}/*"
#         ],
#         "Effect" : "Allow"
#       }
#     ]
#   })
#   tags = merge(var.tags, {
#     Name = "${var.resources_prefix}-unity-catalog external access IAM policy"
#   })
# }

# resource "aws_iam_role" "external_data_access" {
#   name                = "${var.resources_prefix}-external-access"
#   assume_role_policy  = data.aws_iam_policy_document.passrole_for_uc.json
#   managed_policy_arns = [aws_iam_policy.external_data_access.arn]
#   tags = merge(var.tags, {
#     Name = "${var.resources_prefix}-unity-catalog external access IAM role"
#   })
# }

