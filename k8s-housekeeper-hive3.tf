/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "kubernetes_deployment_v1" "apiary_hms_housekeeper_hive3" {
  count = var.hms_instance_type == "k8s" && var.enable_hms_housekeeper && var.hms_enable_hive3 ? 1 : 0
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
          "ad.datadoghq.com/${local.hms_alias}-housekeeper.check_names" = var.datadog_metrics_enabled ? "[\"prometheus\"]" : null
          "ad.datadoghq.com/${local.hms_alias}-housekeeper.init_configs" = var.datadog_metrics_enabled ? "[{}]" : null
          "ad.datadoghq.com/${local.hms_alias}-housekeeper.instances" = var.datadog_metrics_enabled ? "[{ \"prometheus_url\": \"http://%%host%%:${var.datadog_metrics_port}/actuator/prometheus\", \"namespace\": \"hms_readwrite\", \"metrics\": [ \"${join("\",\"", var.datadog_metrics_hms_readwrite_readonly)}\" ] , \"type_overrides\": { \"${join("\": \"gauge\",\"", var.datadog_metrics_hms_readwrite_readonly)}\": \"gauge\"} }]" : null
          "iam.amazonaws.com/role" = var.oidc_provider == "" ? aws_iam_role.apiary_hms_readwrite.name : null
          "prometheus.io/path"     = "/metrics"
          "prometheus.io/port"     = "8080"
          "prometheus.io/scrape"   = "true"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account_v1.hms_readwrite[0].metadata.0.name
        automount_service_account_token = true
        dynamic "init_container" {
          for_each = var.external_database_host == "" ? ["enabled"] : []
          content {
            image = "${var.hms_docker_image_hive3}:${var.hms_docker_version_hive3}"
            name  = "${local.hms_alias}-sql-init-housekeeper"

            command = ["sh", "/allow-grant.sh"]

            env {
              name  = "MYSQL_HOST"
              value = var.external_database_host_hive3 == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host_hive3
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
            value = "1740"
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
            name  = "INSTANCE_NAME"
            value = local.instance_alias
          }
          env {
            name  = "HIVE_METASTORE_LOG_LEVEL"
            value = var.hms_log_level
          }
          env {
            name  = "ENABLE_HIVE_LOCK_HOUSE_KEEPER"
            value = var.enable_hms_housekeeper ? "true" : ""
          }

          env {
            name  = "DATANUCLEUS_CONNECTION_POOLING_TYPE"
            value = var.hms_rw_datanucleus_connection_pooling_type
          }

          env {
            name  = "DATANUCLEUS_CONNECTION_POOL_MAX_POOLSIZE"
            value = var.hms_housekeeper_db_connection_pool_size
          }

          dynamic "env" {
            for_each = var.hms_housekeeper_additional_environment_variables

            content {
              name  = env.key
              value = env.value
            }
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
            limits = {
              cpu    = 0.5
              memory = "2048Mi"
            }
            requests = {
              cpu    = 0.5
              memory = "2048Mi"
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
