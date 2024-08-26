resource "kubernetes_service_account_v1" "hms_readwrite" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readwrite"
    namespace = var.metastore_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.oidc_provider == "" ? "" : aws_iam_role.apiary_hms_readwrite.arn
    }
  }
}

resource "kubernetes_secret_v1" "hms_readwrite" {
  metadata {
    name        = "${local.hms_alias}-readwrite"
    namespace   = var.metastore_namespace
    annotations = {
      "kubernetes.io/service-account.name"      ="${local.hms_alias}-readwrite"
      "kubernetes.io/service-account.namespace" = var.metastore_namespace
    }
  }
  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account_v1.hms_readwrite
  ]
}

resource "kubernetes_service_account_v1" "hms_readonly" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = var.metastore_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.oidc_provider == "" ? "" : aws_iam_role.apiary_hms_readonly.arn
    }
  }
}

resource "kubernetes_secret_v1" "hms_readonly" {
  metadata {
    name        = "${local.hms_alias}-readonly"
    namespace   = var.metastore_namespace
    annotations = {
      "kubernetes.io/service-account.name"      ="${local.hms_alias}-readonly"
      "kubernetes.io/service-account.namespace" = var.metastore_namespace
    }
  }
  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account_v1.hms_readonly
  ]
}

resource "kubernetes_service_account_v1" "s3_inventory" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.instance_alias}-s3-inventory"
    namespace = var.metastore_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.oidc_provider == "" ? "" : aws_iam_role.apiary_s3_inventory.arn
    }
  }
}

resource "kubernetes_secret_v1" "s3_inventory" {
  metadata {
    name        = "${local.instance_alias}-s3-inventory"
    namespace   = var.metastore_namespace
    annotations = {
      "kubernetes.io/service-account.name"      ="${local.instance_alias}-s3-inventory"
      "kubernetes.io/service-account.namespace" = var.metastore_namespace
    }
  }
  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account_v1.s3_inventory
  ]
}
