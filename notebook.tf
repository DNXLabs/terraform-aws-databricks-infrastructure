resource "databricks_notebook" "this" {
  provider = databricks.workspace
  path     = "${path.cwd}/${var.notebook_filename}"
  language = var.notebook_language
  source   = "${path.cwd}/${var.notebook_filename}"
}

output "notebook_url" {
 value = databricks_notebook.this.url
}
