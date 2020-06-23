/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "kubernetes_deployment" "apiary_hms_readonly" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = "metastore"

    labels = {
      name = "${local.hms_alias}-readonly"
    }
  }

  spec {
    replicas = 3
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
          "iam.amazonaws.com/role" = aws_iam_role.apiary_hms_readonly.name
          "prometheus.io/path"     = "/metrics"
          "prometheus.io/port"     = "8080"
          "prometheus.io/scrape"   = "true"
        }
      }

      spec {
        init_container {
          image = "${var.init_container_image}:${var.init_container_version}"
          name  = "${local.hms_alias}-sql-init-readonly"
          
          command = ["sh allow-grant.sh"]
          
          env {
            name = "MYSQL_HOST",
            value = var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host
          }

          env {
            name = "MYSQL_DB",
            value = var.apiary_database_name
          }

          env {
            name = "MYSQL_PERMISSIONS",
            value = "SELECT"
          }
        }

        container {
          image = "${var.hms_docker_image}:${var.hms_docker_version}"
          name  = "${local.hms_alias}-readonly"
          port {
            container_port = 9083
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
            value = "${var.ranger_policy_manager_url}"
          }
          env {
            name  = "RANGER_AUDIT_SOLR_URL"
            value = "${var.ranger_audit_solr_url}"
          }
          env {
            name  = "LDAP_URL"
            value = "${var.ldap_url}"
          }
          env {
            name  = "LDAP_CA_CERT"
            value = "${var.ldap_ca_cert}"
          }
          env {
            name  = "LDAP_BASE"
            value = "${var.ldap_base}"
          }
          env {
            name  = "LDAP_SECRET_ARN"
            value = "${var.ldap_url == "" ? "" : join("", data.aws_secretsmanager_secret.ldap_user.*.arn)}"
          }
          env {
            name  = "HMS_MIN_THREADS"
            value = local.hms_ro_minthreads
          }
          env {
            name  = "HMS_MAX_THREADS"
            value = local.hms_ro_maxthreads
          }

          resources {
            limits {
              memory = "${var.hms_ro_heapsize}Mi"
            }
            requests {
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

resource "kubernetes_service" "hms_readonly" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  metadata {
    name      = "${local.hms_alias}-readonly"
    namespace = "metastore"
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
    type                        = "LoadBalancer"
    load_balancer_source_ranges = var.ingress_cidr
  }
}

data "aws_lb" "k8s_hms_ro_lb" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  name  = split("-", split(".", kubernetes_service.hms_readonly.0.load_balancer_ingress.0.hostname).0).0
}
