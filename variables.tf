/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "instance_name" {
  description = "Apiary instance name to identify resources in multi-instance deployments."
  type        = string
  default     = ""
}

variable "apiary_tags" {
  description = "Common tags that get put on all resources."
  type        = map(any)
}

variable "apiary_domain_name" {
  description = "Apiary domain name for Route 53."
  type        = string
  default     = ""
}

variable "ecs_domain_extension" {
  description = "Domain name to use for hosted zone created by ECS service discovery."
  type        = string
  default     = "lcl"
}

variable "iam_name_root" {
  description = "Name to identify Hive Metastore IAM roles."
  type        = string
  default     = "hms"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnets" {
  description = "Private subnets."
  type        = list(any)
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "apiary_log_bucket" {
  description = "Bucket for Apiary logs."
  type        = string
  default     = ""
}

variable "apiary_log_prefix" {
  description = "Prefix for Apiary logs."
  type        = string
  default     = ""
}

variable "apiary_logs_retention_days" {
  description = "Log retention in days for the Apiary ECS cloudwatch log group."
  type        = "string"
  default     = "30"
}

variable "enable_hive_metastore_metrics" {
  description = "Enable sending Hive Metastore metrics to CloudWatch."
  type        = bool
  default     = false
}

variable "apiary_shared_schemas" {
  description = "Schema names which are accessible from read-only metastore, default is all schemas."
  type        = list(any)
  default     = []
}

variable "apiary_managed_schemas" {
  description = "List of maps, each map contains schema name from which S3 bucket names will be derived, and various properties. The corresponding S3 bucket will be named as apiary_instance-aws_account-aws_region-schema_name."
  type        = list(any)
  default     = []
}

variable "external_data_buckets" {
  description = "Buckets that are not managed by Apiary but added to Hive Metastore IAM role access."
  type        = list(any)
  default     = []
}

variable "external_database_host" {
  description = "External Metastore database host to support legacy installations, MySQL database won't be created by Apiary when this option is specified."
  type        = string
  default     = ""
}

variable "apiary_customer_accounts" {
  description = "AWS account IDs for clients of this Metastore."
  type        = list(any)
}

variable "apiary_assume_roles" {
  description = "Cross account AWS IAM roles allowed write access to managed Apiary S3 buckets using assume policy."
  type        = list(any)
  default     = []
}

variable "apiary_producer_iamroles" {
  description = "AWS IAM roles allowed write access to managed Apiary S3 buckets."
  type        = map(any)
  default     = {}
}

variable "apiary_rds_additional_sg" {
  description = "Comma-separated string containing additional security groups to attach to RDS."
  type        = list(any)
  default     = []
}

variable "apiary_database_name" {
  description = "Database name to create in RDS for Apiary."
  type        = string
  default     = "apiary"
}

variable "db_master_username" {
  description = "Aurora cluster MySQL master user name."
  type        = string
  default     = "apiary"
}

variable "db_rw_secret_name" {
  description = "Aurora cluster MySQL read/write user SecretsManager secret name."
  type        = string
  default     = ""
}

variable "db_ro_secret_name" {
  description = "Aurora cluster MySQL read-only user SecretsManger secret name."
  type        = string
  default     = ""
}

variable "db_instance_class" {
  description = "Instance type for the RDS Metastore DB."
  type        = string
}

variable "db_instance_count" {
  description = "Desired count of database cluster instances."
  type        = string
  default     = "2"
}

variable "db_backup_retention" {
  description = "The number of days to retain backups for the RDS Metastore DB."
  type        = string
}

variable "db_apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "db_backup_window" {
  description = "Preferred backup window for the RDS Metastore DB in UTC."
  type        = string
  default     = "02:00-03:00"
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window for the RDS Metastore DB in UTC."
  type        = string
  default     = "wed:03:00-wed:04:00"
}

variable "hms_instance_type" {
  description = "Hive Metastore instance type, possible values: ecs,k8s."
  type        = string
  default     = "ecs"
}

variable "hms_log_level" {
  description = "Log level for the Hive Metastore."
  type        = string
  default     = "INFO"
}

variable "hms_ro_heapsize" {
  description = <<EOF
Heapsize for the read only Hive Metastore.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = "2048"
}

variable "hms_rw_heapsize" {
  description = <<EOF
Heapsize for the read/write Hive Metastore.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = "2048"
}

variable "hms_ro_cpu" {
  description = <<EOF
CPU for the read only Hive Metastore ECS task.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = "512"
}

variable "hms_rw_cpu" {
  description = <<EOF
CPU for the read/write Hive Metastore ECS task.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = "512"
}

variable "hms_nofile_ulimit" {
  description = "Ulimit for the Hive Metastore container."
  type        = string
  default     = "32768"
}

variable "hms_docker_image" {
  description = "Docker image ID for the Hive Metastore."
  type        = string
}

variable "hms_docker_version" {
  description = "Version of the Docker image for the Hive Metastore."
  type        = string
}

variable "hms_rw_ecs_task_count" {
  description = "Desired ECS task count of the read/write Hive Metastore service."
  type        = string
  default     = "3"
}

variable "hms_ro_ecs_task_count" {
  description = "Desired ECS task count of the read only Hive Metastore service."
  type        = string
  default     = "3"
}

variable "elb_timeout" {
  description = "Idle timeout for Apiary ELB."
  type        = string
  default     = "1800"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress CIDR list."
  type        = list(any)
}

variable "enable_gluesync" {
  description = "Enable metadata sync from Hive to the Glue catalog."
  type        = bool
  default     = false
}

variable "enable_metadata_events" {
  description = "Enable Hive Metastore SNS listener."
  type        = bool
  default     = false
}

variable "table_param_filter" {
  description = "A regular expression for selecting necessary table parameters for the SNS listener. If the value isn't set, then no table parameters are selected."
  type        = string
  default     = ""
}

variable "enable_data_events" {
  description = "Enable managed buckets S3 event notifications."
  type        = bool
  default     = false
}

variable "enable_s3_paid_metrics" {
  description = "Enable managed S3 buckets request and data transfer metrics."
  type        = bool
  default     = false
}

variable "s3_enable_inventory" {
  description = "Enable S3 inventory configuration."
  type        = bool
  default     = false
}

variable "s3_inventory_format" {
  description = "Output format for S3 inventory results. Can be Parquet, ORC, CSV"
  type        = string
  default     = "ORC"
}

variable "ranger_policy_manager_url" {
  description = "Ranger admin URL to synchronize policies."
  type        = string
  default     = ""
}

variable "ranger_audit_solr_url" {
  description = "Ranger Solr audit provider configuration."
  type        = string
  default     = ""
}

variable "ranger_audit_db_url" {
  description = "Ranger DB audit provider configuration."
  type        = string
  default     = ""
}

variable "ranger_audit_secret_name" {
  description = "Ranger DB audit secret name."
  type        = string
  default     = ""
}

variable "ldap_url" {
  description = "Active directory LDAP URL to configure Hadoop LDAP group mapping."
  type        = string
  default     = ""
}

variable "ldap_ca_cert" {
  description = "Base64 encoded Certificate Authority bundle to validate LDAPS connections."
  type        = string
  default     = ""
}

variable "ldap_base" {
  description = "Active directory LDAP base DN to search users and groups."
  type        = string
  default     = ""
}

variable "ldap_secret_name" {
  description = "Active directory LDAP bind DN SecretsManager secret name."
  type        = string
  default     = ""
}

variable "secondary_vpcs" {
  description = "List of VPCs to associate with Service Discovery namespace."
  type        = list(any)
  default     = []
}

variable "docker_registry_auth_secret_name" {
  description = "Docker Registry authentication SecretManager secret name."
  type        = string
  default     = ""
}

variable "k8s_docker_registry_secret" {
  description = "Docker Registry authentication K8s secret name."
  type        = string
  default     = ""
}

variable "atlas_kafka_bootstrap_servers" {
  description = "Kafka instance url."
  type        = string
  default     = ""
}

variable "atlas_cluster_name" {
  description = "Name of the Atlas cluster where metastore plugin will send DDL events.  Defaults to `var.instance_name` if not set."
  type        = string
  default     = ""
}

variable "kiam_arn" {
  description = "Kiam server IAM role ARN."
  type        = string
  default     = ""
}

variable "s3_storage_class" {
  description = "S3 storage class after transition using lifecycle policy"
  type        = string
  default     = "INTELLIGENT_TIERING"
}

variable "s3_lifecycle_policy_transition_period" {
  description = "S3 Lifecycle Policy number of days for Transition rule"
  type        = string
  default     = "30"
}

variable "s3_lifecycle_abort_incomplete_multipart_upload_days" {
  description = "Number of days after which incomplete multipart uploads will be deleted."
  type        = string
  default     = "7"
}

variable "s3_log_expiry" {
  description = "Number of days after which Apiary S3 bucket logs expire."
  type        = string
  default     = "365"
}

variable "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers to send metastore events, setting this enables Hive Metastore Kafka listener."
  type        = string
  default     = ""
}

variable "kafka_topic_name" {
  description = "Kafka topic to send metastore events."
  type        = string
  default     = ""
}

variable "s3_inventory_update_schedule" {
  description = "Cron schedule to update S3 inventory tables (if enabled). Defaults to every 12 hours."
  type        = string
  default     = "0 */12 * * *"
}
