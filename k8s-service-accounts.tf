resource "kubernetes_service_account" "hms_readwrite" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readwrite"
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.oidc_provider == "" ? "" : aws_iam_role.apiary_hms_readwrite.arn
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account" "hms_readonly" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.oidc_provider == "" ? "" : aws_iam_role.apiary_hms_readonly.arn
    }
  }
  automount_service_account_token = true
}
