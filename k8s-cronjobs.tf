/**
 * Copyright (C) 2018-2020 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "kubernetes_cron_job" "apiary_inventory_repair" {
  count = (var.s3_enable_inventory && var.hms_instance_type == "k8s") ? 1 : 0
  metadata {
    name      = "s3-inventory-repair"
    namespace = "metastore"

    labels = {
      name = "s3-inventory-repair"
    }
  }

  spec {
    concurrency_policy = "Replace"
    failed_jobs_history_limit = 5
    schedule = var.s3_inventory_update_schedule

    job_template {
      metadata {}
      spec {
        template {
          metadata {
            labels = {
              name = "s3-inventory-repair"
            }
            annotations = {
              "iam.amazonaws.com/role" = aws_iam_role.apiary_hms_readonly.name
            }
          }

          spec {
            container {
              image   = "${var.hms_docker_image}:${var.hms_docker_version}"
              name    = "s3-inventory-repair"
              command = [ "/s3_inventory_repair.sh" ]
              env {
                name = "AWS_REGION"
                value = var.aws_region
              }
              env {
                name = "AWS_DEFAULT_REGION"
                value = var.aws_region
              }
              env {
                name = "HIVE_DB_NAMES"
                value = join(",", local.apiary_managed_schema_names_original)
              }
              env {
                name = "INSTANCE_NAME"
                value = local.instance_alias
              }
              env {
                name = "HIVE_METASTORE_LOG_LEVEL"
                value = var.hms_log_level
              }
              env {
                name = "ENABLE_S3_INVENTORY"
                value = var.s3_enable_inventory
              }
              env {
                name = "APIARY_S3_INVENTORY_TABLE_FORMAT"
                value = var.s3_inventory_format
              }
              env {
                name = "APIARY_S3_INVENTORY_PREFIX"
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