/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "kubernetes_deployment_v1" "apiary_hms_readonly" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = var.metastore_namespace

    labels = {
      name = "${local.hms_alias}-readonly"
    }
  }

  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = var.hms_ro_k8s_rolling_update_strategy.max_surge
        max_unavailable = var.hms_ro_k8s_rolling_update_strategy.max_unavailable
      }
    }
    replicas = var.hms_ro_k8s_replica_count
    selector {
      match_labels = {
        name = "${local.hms_alias}-readonly"
      }
    }

    template {
      metadata {
        labels = {
          name = "${local.hms_alias}-readonly"
        }
        annotations = {
          "ad.datadoghq.com/${local.hms_alias}-readonly.check_names" = var.datadog_metrics_enabled ? "[\"prometheus\"]" : null
          "ad.datadoghq.com/${local.hms_alias}-readonly.init_configs" = var.datadog_metrics_enabled ? "[{}]" : null
          "ad.datadoghq.com/${local.hms_alias}-readonly.instances" = var.datadog_metrics_enabled ? "[{ \"prometheus_url\": \"http://%%host%%:${var.datadog_metrics_port}/actuator/prometheus\", \"namespace\": \"hms_readonly\", \"metrics\": [ \"${join("\",\"", var.datadog_metrics_hms_readwrite_readonly)}\" ] , \"type_overrides\": { \"${join("\": \"gauge\",\"", var.datadog_metrics_hms_readwrite_readonly)}\": \"gauge\"} }]"  : null
          "iam.amazonaws.com/role" = var.oidc_provider == "" ? aws_iam_role.apiary_hms_readonly.name : null
          "prometheus.io/path"     = "/metrics"
          "prometheus.io/port"     = "8080"
          "prometheus.io/scrape"   = "true"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account_v1.hms_readonly[0].metadata.0.name
        automount_service_account_token = true

        dynamic "toleration" {
          for_each = var.hms_ro_tolerations
          content {
            effect             = lookup(toleration.value, "effect", null)
            key                = lookup(toleration.value, "key", null)
            operator           = lookup(toleration.value, "operator", null)
            value              = lookup(toleration.value, "value", null)
          }
        }

        dynamic "affinity" {
          for_each = var.hms_ro_node_affinity
          content {
            node_affinity {
              required_during_scheduling_ignored_during_execution {
                dynamic "node_selector_term" {
                  for_each = lookup(affinity.value, "node_selector_term", [])
                  content {
                    match_expressions {
                      key      = lookup(node_selector_term.value, "key", null)
                      operator = lookup(node_selector_term.value, "operator", null)
                      values   = lookup(node_selector_term.value, "values", [])
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "security_context"  {
          for_each = var.enable_tcp_keepalive ? ["enabled"] : []
          content {
            sysctl {
              name  = "net.ipv4.tcp_keepalive_time"
              value = var.tcp_keepalive_time
            }
            sysctl {
              name  = "net.ipv4.tcp_keepalive_intvl"
              value = var.tcp_keepalive_intvl
            }
            sysctl {
              name  = "net.ipv4.tcp_keepalive_probes"
              value = var.tcp_keepalive_probes
            }
          }
        }

        dynamic "init_container" {
          for_each = var.external_database_host == "" ? ["enabled"] : []

          content {
            image = "${var.hms_docker_image}:${var.hms_docker_version}"
            name  = "${local.hms_alias}-sql-init-readonly"

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
              value = "SELECT"
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
                  key  = "ro_creds"
                }
              }
            }
          }
        }

        container {
          image = "${var.hms_docker_image}:${var.hms_docker_version}"
          name  = "${local.hms_alias}-readonly"
          port {
            container_port = var.hive_metastore_port
          }
          env {
            name  = "MYSQL_DB_HOST"
            value = var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.reader_endpoint) : coalesce(var.external_database_host_readonly,var.external_database_host)
          }
          env {
            name  = "MYSQL_DB_NAME"
            value = var.apiary_database_name
          }
          env {
            name  = "MYSQL_SECRET_ARN"
            value = data.aws_secretsmanager_secret.db_ro_user.arn
          }
          env {
            name  = "HIVE_METASTORE_ACCESS_MODE"
            value = "readonly"
          }
          env {
            name  = "HADOOP_HEAPSIZE"
            value = local.hms_ro_heapsize
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
            name  = "HIVE_DB_WHITELIST"
            value = join(",", var.apiary_shared_schemas)
          }
          env {
            name  = "INSTANCE_NAME"
            value = local.instance_alias
          }
          env {
            name  = "ENABLE_METRICS"
            value = var.enable_hive_metastore_metrics ? "1" : ""
          }
          env {
            name  = "HIVE_METASTORE_LOG_LEVEL"
            value = var.hms_log_level
          }
          env {
            name  = "RANGER_SERVICE_NAME"
            value = "${local.instance_alias}-metastore"
          }
          env {
            name  = "RANGER_POLICY_MANAGER_URL"
            value = var.ranger_policy_manager_url
          }
          env {
            name  = "RANGER_AUDIT_SOLR_URL"
            value = var.ranger_audit_solr_url
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
            name  = "HMS_MIN_THREADS"
            value = local.hms_ro_minthreads
          }
          env {
            name  = "HMS_MAX_THREADS"
            value = local.hms_ro_maxthreads
          }
          env {
            name  = "HMS_AUTOGATHER_STATS"
            value = "false"
          }
          env {
            name  = "LIMIT_PARTITION_REQUEST_NUMBER"
            value = var.hms_ro_request_partition_limit == "" ? "" : var.hms_ro_request_partition_limit
          }
          env {
            name  = "DATANUCLEUS_CONNECTION_POOLING_TYPE"
            value = var.hms_ro_datanucleus_connection_pooling_type
          }
          env {
            name  = "DATANUCLEUS_CONNECTION_POOL_MAX_POOLSIZE"
            value = var.hms_ro_db_connection_pool_size
          }

          dynamic "env" {
            for_each = var.hms_additional_environment_variables

            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = var.hms_ro_datanucleus_connection_pool_config

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
              cpu    = local.k8s_ro_cpu_limit
              memory = "${var.hms_ro_heapsize}Mi"
            }
            requests = {
              cpu    = local.k8s_ro_cpu
              memory = "${var.hms_ro_heapsize}Mi"
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

resource "kubernetes_horizontal_pod_autoscaler" "hms_readonly" {
  count = var.hms_instance_type == "k8s" && var.enable_autoscaling ? 1 : 0

  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = var.metastore_namespace
  }

  spec {
    min_replicas = var.hms_ro_k8s_replica_count
    max_replicas = var.hms_ro_k8s_max_replica_count

    target_cpu_utilization_percentage = var.hms_ro_target_cpu_percentage

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.apiary_hms_readonly[0].metadata[0].name
    }
  }
}

resource "kubernetes_service" "hms_readonly" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = var.metastore_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
    }
  }
  spec {
    selector = {
      name = "${local.hms_alias}-readonly"
    }
    port {
      port        = 9083
      target_port = 9083
    }
    type                        = var.enable_vpc_endpoint_services ? "LoadBalancer" : "ClusterIP"
    load_balancer_source_ranges = var.enable_vpc_endpoint_services ? local.ro_ingress_cidr : null
  }
}

data "aws_lb" "k8s_hms_ro_lb" {
  count = var.hms_instance_type == "k8s" && var.enable_vpc_endpoint_services ? 1 : 0
  name  = split("-", split(".", kubernetes_service.hms_readonly[0].status.0.load_balancer.0.ingress.0.hostname).0).0
}

resource "kubernetes_pod_disruption_budget_v1" "hms_readonly" {
  count = var.hms_instance_type == "k8s" && var.hms_ro_k8s_pdb_settings.enabled ? 1 : 0

  metadata {
    name = "${local.hms_alias}-readonly"
    namespace = var.metastore_namespace
  }

  spec {
    selector {
      match_labels = {
        name = "${local.hms_alias}-readonly"
      }
    }

    # set max_unavailable to 1 by default if PDB is created
    max_unavailable = var.hms_ro_k8s_pdb_settings.max_unavailable != null ? var.hms_ro_k8s_pdb_settings.max_unavailable : "1"
    min_available   = var.hms_ro_k8s_pdb_settings.min_available != null ? var.hms_ro_k8s_pdb_settings.min_available : null
  }
}