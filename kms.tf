resource "aws_kms_key" "apiary_kms" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if schema["encryption"] == "aws:kms"
  }

  description = "Apiary ${each.key} KMS key" 
  policy      = data.template_file.apiary_kms_key_policy[each.key].rendered

  lifecycle {
    prevent_destroy = true
  }
}

data "template_file" "apiary_kms_key_policy" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if schema["encryption"] == "aws:kms"
  }

  template = file("${path.module}/templates/apiary-kms-key-policy.json")

  vars = {
    admin_roles  = replace(each.value["admin_roles"], ",", "\",\"")
    client_roles = replace(lookup(each.value, "client_roles", ""), ",", "\",\"")
  }
}

resource "aws_kms_alias" "apiary_alias" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if schema["encryption"] == "aws:kms"
  }

  name          = "alias/${local.instance_alias}/${each.value["schema_name"]}"
  target_key_id = aws_kms_key.apiary_kms[each.key].key_id
}
