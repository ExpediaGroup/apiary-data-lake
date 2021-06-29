resource "kubernetes_secret" "hms_secrets" {
  count = var.external_database_host == "" && var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-credentials"
    namespace = var.k8s_namespace
  }

  data = {
    master_creds = aws_secretsmanager_secret_version.apiary_mysql_master_credentials[0].secret_string
    ro_creds     = data.aws_secretsmanager_secret_version.db_ro_user.secret_string
    rw_creds     = data.aws_secretsmanager_secret_version.db_rw_user.secret_string
  }
}
