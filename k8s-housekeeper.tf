/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "kubernetes_deployment" "apiary_hms_housekeeper" {
  count = var.hms_instance_type == "k8s" && var.enable_hms_housekeeper ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-housekeeper"
    namespace = var.metastore_namespace

    labels = {
      name = "${local.hms_alias}-housekeeper"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "${local.hms_alias}-housekeeper"
      }
    }

    template {
      metadata {
        labels = {
          name = "${local.hms_alias}-housekeeper"
        }
        annotations = {
          "iam.amazonaws.com/role" = aws_iam_role.apiary_hms_readwrite.name
          "prometheus.io/path"     = "/metrics"
          "prometheus.io/port"     = "8080"
          "prometheus.io/scrape"   = "true"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.hms_readwrite[0].metadata.0.name
        automount_service_account_token = true
        dynamic "init_container" {
          for_each = var.external_database_host == "" ? ["enabled"] : []
          content {
            image = "${var.hms_docker_image}:${var.hms_docker_version}"
            name  = "${local.hms_alias}-sql-init-housekeeper"

            command = ["sh", "/allow-grant.sh"]

            env {
              name  = "MYSQL_HOST"
              value = var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host
            }

            env {
              name  = "MYSQL_DB"
              value = var.apiary_database_name
            }

            env {
              name  = "MYSQL_PERMISSIONS"
              value = "ALL"
            }

            env {
              name = "MYSQL_MASTER_CREDS"
              value_from {
                secret_key_ref {
                  name = kubernetes_secret.hms_secrets[0].metadata[0].name
                  key  = "master_creds"
                }
              }
            }

            env {
              name = "MYSQL_USER_CREDS"
              value_from {
                secret_key_ref {
                  name = kubernetes_secret.hms_secrets[0].metadata[0].name
                  key  = "rw_creds"
                }
              }
            }
          }
        }

        container {
          image = "${var.hms_docker_image}:${var.hms_docker_version}"
          name  = "${local.hms_alias}-housekeeper"
          port {
            container_port = var.hive_metastore_port
          }
          env {
            name  = "MYSQL_DB_HOST"
            value = var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host
          }
          env {
            name  = "MYSQL_DB_NAME"
            value = var.apiary_database_name
          }
          env {
            name  = "MYSQL_SECRET_ARN"
            value = data.aws_secretsmanager_secret.db_rw_user.arn
          }
          env {
            name  = "HIVE_METASTORE_ACCESS_MODE"
            value = "readwrite"
          }
          env {
            name  = "HADOOP_HEAPSIZE"
            value = local.hms_rw_heapsize
          }
          env {
            name  = "AWS_REGION"
            value = var.aws_region
          }
          env {
            name  = "AWS_DEFAULT_REGION"
            value = var.aws_region
          }
          env {
            name  = "HIVE_DB_NAMES"
            value = join(",", local.schemas_info[*]["schema_name"])
          }
          env {
            name  = "INSTANCE_NAME"
            value = local.instance_alias
          }
          env {
            name  = "HIVE_METASTORE_LOG_LEVEL"
            value = var.hms_log_level
          }
          env {
            name  = "LDAP_URL"
            value = var.ldap_url
          }
          env {
            name  = "LDAP_CA_CERT"
            value = var.ldap_ca_cert
          }
          env {
            name  = "LDAP_BASE"
            value = var.ldap_base
          }
          env {
            name  = "LDAP_SECRET_ARN"
            value = var.ldap_url == "" ? "" : join("", data.aws_secretsmanager_secret.ldap_user.*.arn)
          }
          env {
            name  = "ENABLE_HIVE_LOCK_HOUSE_KEEPER"
            value = var.enable_hms_housekeeper ? "true" : ""
          }

          liveness_probe {
            tcp_socket {
              port = var.hive_metastore_port
            }
            timeout_seconds       = 60
            failure_threshold     = 3
            success_threshold     = 1
            initial_delay_seconds = 60
            period_seconds        = 20
          }

          readiness_probe {
            tcp_socket {
              port = var.hive_metastore_port
            }
            timeout_seconds       = 60
            failure_threshold     = 3
            success_threshold     = 1
            initial_delay_seconds = 60
            period_seconds        = 20
          }

          resources {
            limits {
              cpu    = local.k8s_rw_cpu_limit
              memory = "${var.hms_rw_heapsize}Mi"
            }
            requests {
              cpu    = local.k8s_rw_cpu
              memory = "${var.hms_rw_heapsize}Mi"
            }
          }
        }
        image_pull_secrets {
          name = var.k8s_docker_registry_secret
        }
      }
    }
  }
}