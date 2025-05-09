resource "aws_s3control_storage_lens_configuration" "lens" {
  config_id  = var.storage_lens_config.config_id
  account_id = data.aws_caller_identity.current.account_id

  storage_lens_configuration {
    enabled = var.storage_lens_config.enabled

    account_level {
      activity_metrics {
        enabled = var.storage_lens_config.account_level.activity_metrics
      }

      advanced_cost_optimization_metrics {
        enabled = var.storage_lens_config.account_level.advanced_cost_optimization_metrics
      }

      advanced_data_protection_metrics {
        enabled = var.storage_lens_config.account_level.advanced_data_protection_metrics
      }

      detailed_status_code_metrics {
        enabled = var.storage_lens_config.account_level.detailed_status_code_metrics
      }

      bucket_level {
        activity_metrics {
          enabled = var.storage_lens_config.bucket_level.activity_metrics
        }

        advanced_cost_optimization_metrics {
          enabled = var.storage_lens_config.bucket_level.advanced_cost_optimization_metrics
        }

        advanced_data_protection_metrics {
          enabled = var.storage_lens_config.bucket_level.advanced_data_protection_metrics
        }

        detailed_status_code_metrics {
          enabled = var.storage_lens_config.bucket_level.detailed_status_code_metrics
        }

      }
    }

    dynamic "include" {
        for_each = var.storage_lens_config.include.enabled ? [1] : []
        content {
            buckets = length(var.storage_lens_config.include.buckets) > 0 ? var.storage_lens_config.include.buckets : [ for schema in local.schemas_info : schema.data_bucket ]
            regions = [var.aws_region]
        }
    }

    dynamic "include" {
        for_each = var.storage_lens_config.exclude.enabled ? [1] : []
        content {
            buckets = length(var.storage_lens_config.exclude.buckets) > 0 ? var.storage_lens_config.exclude.buckets : [ for schema in local.schemas_info : schema.data_bucket ]
            regions = [var.aws_region]
        }
    }

    dynamic "data_export" {
        for_each = var.storage_lens_config.data_export.enabled ? [1] : []

        content {
            s3_bucket_destination {
            account_id = data.aws_caller_identity.current.account_id
            arn = var.storage_lens_config.data_export.destination_bucket_arn != "" ?
                var.storage_lens_config.data_export.destination_bucket_arn :
                aws_s3_bucket.apiary_system.arn

            format                = var.storage_lens_config.data_export.format
            output_schema_version = "V_1"

            encryption {
                sse_s3 {}
            }
            }

            cloud_watch_metrics {
                enabled = true
            }
        }
    }

  }
}