locals {
  hms_rw_heapsize = ceil((var.hms_rw_heapsize * 90) / 100)
}

resource "kubernetes_deployment" "apiary_hms_readwrite" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  metadata {
    name      = "hms-readwrite"
    namespace = "metastore"

    labels = {
      name = "hms-readwrite"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        name = "hms-readwrite"
      }
    }

    template {
      metadata {
        labels = {
          name = "hms-readwrite"
        }
        annotations = {
          "iam.amazonaws.com/role" = aws_iam_role.apiary_hms_readwrite.name
        }
      }

      spec {
        container {
          image = "${var.hms_docker_image}:${var.hms_docker_version}"
          name  = "hms-readwrite"

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
            value = join(",", local.apiary_managed_schema_names_original)
          }
          env {
            name  = "INSTANCE_NAME"
            value = local.instance_alias
          }
          env {
            name  = "SNS_ARN"
            value = var.enable_metadata_events == "" ? "" : join("", aws_sns_topic.apiary_metadata_events.*.arn)
          }
          env {
            name  = "TABLE_PARAM_FILTER"
            value = var.enable_metadata_events == "" ? "" : var.table_param_filter
          }
          env {
            name  = "ENABLE_METRICS"
            value = var.enable_hive_metastore_metrics
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
    name      = "hms-readwrite"
    namespace = "metastore"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
    }
  }
  spec {
    selector = {
      name = "hms-readwrite"
    }
    port {
      port        = 9083
      target_port = 9083
    }
    type                        = "LoadBalancer"
    load_balancer_source_ranges = [data.aws_vpc.apiary_vpc.cidr_block]
  }
}

data "aws_lb" "k8s_hms_rw_lb" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  name  = split("-", split(".", kubernetes_service.hms_readwrite.0.load_balancer_ingress.0.hostname).0).0
}
