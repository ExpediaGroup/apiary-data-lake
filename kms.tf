resource "aws_kms_key" "apiary_kms" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if schema["encryption"] == "aws:kms"
  }

  description = "apiary ${each.key} kms key"
  //policy      = "${data.template_file.vault_kms_key_policy.rendered}"

  lifecycle {
    prevent_destroy = true
  }
}
