resource "kubernetes_service_account" "hms_readwrite" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readwrite"
    namespace = "metastore"
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account" "hms_readonly" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = "metastore"
  }
  automount_service_account_token = true
}
