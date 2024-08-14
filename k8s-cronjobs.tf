/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "kubernetes_cron_job_v1" "apiary_inventory" {
  count = (var.s3_enable_inventory && var.hms_instance_type == "k8s") ? 1 : 0
  metadata {
    name      = "${local.instance_alias}-s3-inventory"
    namespace = var.metastore_namespace

    labels = {
      name = "${local.instance_alias}-s3-inventory"
    }
  }

  spec {
    concurrency_policy        = "Replace"
    failed_jobs_history_limit = 5
    schedule                  = var.s3_inventory_update_schedule

    job_template {
      metadata {}
      spec {
        template {
          metadata {
            labels = {
              name = "${local.instance_alias}-s3-inventory"
            }
            annotations = {
              "iam.amazonaws.com/role" = var.oidc_provider == "" ? aws_iam_role.apiary_s3_inventory.name : null
            }
          }

          spec {
            service_account_name            = kubernetes_service_account_v1.s3_inventory[0].metadata.0.name
            automount_service_account_token = true
            container {
              image   = "${var.hms_docker_image}:${var.hms_docker_version}"
              name    = "${local.instance_alias}-s3-inventory"
              command = ["/s3_inventory_repair.sh"]
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
                name  = "APIARY_RW_METASTORE_URI"
                value = "thrift://${kubernetes_service.hms_readwrite[0].metadata[0].name}.${kubernetes_service.hms_readwrite[0].metadata[0].namespace}.svc.cluster.local:9083"
              }
              env {
                name  = "HIVE_METASTORE_LOG_LEVEL"
                value = var.hms_log_level
              }
              env {
                name  = "ENABLE_S3_INVENTORY"
                value = var.s3_enable_inventory
              }
              env {
                name  = "APIARY_S3_INVENTORY_TABLE_FORMAT"
                value = var.s3_inventory_format
              }
              env {
                name  = "APIARY_S3_INVENTORY_PREFIX"
                value = local.s3_inventory_prefix
              }
            }
            image_pull_secrets {
              name = var.k8s_docker_registry_secret
            }
          }
        }
      }
    }
  }
}
