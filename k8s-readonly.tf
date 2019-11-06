resource "kubernetes_deployment" "apiary_hms_readonly" {
  metadata {
    name      = "hms-readonly"
    namespace = "metastore"

    labels = {
      name = "hms-readonly"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        name = "hms-readonly"
      }
    }

    template {
      metadata {
        labels = {
          name = "hms-readonly"
        }
        annotations = {
          "iam.amazonaws.com/role" = aws_iam_role.apiary_hms_readonly.name
        }
      }

      spec {
        container {
          image = "${var.hms_docker_image}:${var.hms_docker_version}"
          name  = "hms-readonly"

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
            value = var.hms_ro_heapsize
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
            name  = "ENABLE_METRICS"
            value = var.enable_hive_metastore_metrics
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
  metadata {
    name      = "hms-readonly"
    namespace = "metastore"
  }
  spec {
    selector = {
      name = "hms-readonly"
    }
    session_affinity = "ClientIP"
    port {
      port        = 9083
      target_port = 9083
    }
    type = "ClusterIP"
  }
}
