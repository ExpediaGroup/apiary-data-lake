/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "kubernetes_deployment" "apiary_hms_readwrite" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  metadata {
    name      = "${local.hms_alias}-readwrite"
    namespace = "metastore"

    labels = {
      name = "${local.hms_alias}-readwrite"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        name = "${local.hms_alias}-readwrite"
      }
    }

    template {
      metadata {
        labels = {
          name = "${local.hms_alias}-readwrite"
        }
        annotations = {
          "iam.amazonaws.com/role" = aws_iam_role.apiary_hms_readwrite.name
          "prometheus.io/path"     = "/metrics"
          "prometheus.io/port"     = "8080"
          "prometheus.io/scrape"   = "true"
        }
      }

      spec {
        container {
          image = "${var.hms_docker_image}:${var.hms_docker_version}"
          name  = "${local.hms_alias}-readwrite"
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
            name  = "SNS_ARN"
            value = var.enable_metadata_events ? join("", aws_sns_topic.apiary_metadata_events.*.arn) : ""
          }
          env {
            name  = "TABLE_PARAM_FILTER"
            value = var.enable_metadata_events ? var.table_param_filter : ""
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
            name  = "ATLAS_KAFKA_BOOTSTRAP_SERVERS"
            value = "${var.atlas_kafka_bootstrap_servers}"
          }
          env {
            name  = "ATLAS_CLUSTER_NAME"
            value = "${local.final_atlas_cluster_name}"
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
            name  = "KAFKA_BOOTSTRAP_SERVERS"
            value = var.kafka_bootstrap_servers
          }
          env {
            name  = "KAFKA_TOPIC_NAME"
            value = var.kafka_topic_name
          }
          env {
            name  = "ENABLE_S3_INVENTORY"
            value = var.s3_enable_inventory ? "1" : ""
          }
          env {
            # If user sets "apiary_log_bucket", then they are doing their own access logs mgmt, and not using Apiary's log mgmt.
            name  = "ENABLE_S3_LOGS"
            value = local.enable_apiary_s3_log_management ? "1" : ""
          }
          env {
            name  = "HMS_MIN_THREADS"
            value = local.hms_rw_minthreads
          }
          env {
            name  = "HMS_MAX_THREADS"
            value = local.hms_rw_maxthreads
          }
          env {
            name  = "APIARY_SYSTEM_SCHEMA"
            value = var.system_schema_name
          }

          resources {
            limits {
              memory = "${var.hms_rw_heapsize}Mi"
            }
            requests {
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

resource "kubernetes_service" "hms_readwrite" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  metadata {
    name      = "${local.hms_alias}-readwrite"
    namespace = "metastore"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
    }
  }
  spec {
    selector = {
      name = "${local.hms_alias}-readwrite"
    }
    port {
      port        = 9083
      target_port = 9083
    }
    type                        = "LoadBalancer"
    load_balancer_source_ranges = var.ingress_cidr
  }
}

data "aws_lb" "k8s_hms_rw_lb" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  name  = split("-", split(".", kubernetes_service.hms_readwrite.0.load_balancer_ingress.0.hostname).0).0
}
