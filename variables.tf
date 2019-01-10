/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "instance_name" {
  description = "Apiary instance name to identify resources in multi-instance deployments."
  type        = "string"
  default     = ""
}

variable "apiary_tags" {
  description = "Common tags that get put on all resources."
  type        = "map"
}

variable "apiary_domain_name" {
  description = "Apiary domain name for Route 53."
  type        = "string"
  default     = ""
}

variable "ecs_domain_extension" {
  description = "Domain name to use for hosted zone created by ECS service discovery."
  type        = "string"
  default     = "lcl"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = "string"
}

variable "private_subnets" {
  description = "Private subnets."
  type        = "list"
}

variable "aws_region" {
  description = "AWS region."
  type        = "string"
}

variable "apiary_log_bucket" {
  description = "Bucket for Apiary logs."
  type        = "string"
}

variable "apiary_log_prefix" {
  description = "Prefix for Apiary logs."
  type        = "string"
  default     = ""
}

variable "enable_hive_metastore_metrics" {
  description = "Enable sending Hive Metastore metrics to CloudWatch."
  type        = "string"
  default     = ""
}

variable "apiary_shared_schemas" {
  description = "Schema names which are accessible from read-only metastore, default is all schemas."
  type        = "list"
  default     = []
}

variable "apiary_managed_schemas" {
  description = "Schema names from which S3 bucket names will be derived, corresponding S3 bucket will be named as apiary_instance-aws_account-aws_region-schema_name."
  type        = "list"
  default     = []
}

variable "external_data_buckets" {
  description = "Buckets that are not managed by Apiary but added to Hive Metastore IAM role access."
  type        = "list"
  default     = []
}

variable "external_database_host" {
  description = "External Metastore database host to support legacy installations, MySQL database won't be created by Apiary when this option is specified."
  type        = "string"
  default     = ""
}

variable "apiary_customer_accounts" {
  description = "AWS account IDs for clients of this Metastore."
  type        = "list"
}

variable "apiary_producer_iamroles" {
  description = "AWS IAM roles allowed write access to managed Apiary S3 buckets."
  type        = "map"
  default     = {}
}

variable "apiary_rds_additional_sg" {
  description = "Comma-separated string containing additional security groups to attach to RDS."
  type        = "list"
  default     = []
}

variable "apiary_database_name" {
  description = "Database name to create in RDS for Apiary."
  type        = "string"
  default     = "apiary"
}

variable "db_master_username" {
  description = "Aurora cluster MySQL master user name."
  type        = "string"
  default     = "apiary"
}

variable "db_rw_secret_name" {
  description = "Aurora cluster MySQL read/write user SecretsManager secret name."
  type        = "string"
  default     = ""
}

variable "db_ro_secret_name" {
  description = "Aurora cluster MySQL read-only user SecretsManger secret name."
  type        = "string"
  default     = ""
}

variable "db_instance_class" {
  description = "Instance type for the RDS Metastore DB."
  type        = "string"
}

variable "db_instance_count" {
  description = "Desired count of database cluster instances."
  type        = "string"
  default     = "2"
}

variable "db_backup_retention" {
  description = "The number of days to retain backups for the RDS Metastore DB."
  type        = "string"
}

variable "db_apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
  type        = "string"
  default     = "false"
}

variable "db_backup_window" {
  description = "Preferred backup window for the RDS Metastore DB in UTC."
  type        = "string"
  default     = "02:00-03:00"
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window for the RDS Metastore DB in UTC."
  type        = "string"
  default     = "wed:03:00-wed:04:00"
}

variable "hms_log_level" {
  description = "Log level for the Hive Metastore."
  type        = "string"
  default     = "INFO"
}

variable "hms_ro_heapsize" {
  description = <<EOF
Heapsize for the read only Hive Metastore.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type = "string"
}

variable "hms_rw_heapsize" {
  description = <<EOF
Heapsize for the read/write Hive Metastore.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type = "string"
}

variable "hms_ro_cpu" {
  description = <<EOF
CPU for the read only Hive Metastore ECS task.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "512"
}

variable "hms_rw_cpu" {
  description = <<EOF
CPU for the read/write Hive Metastore ECS task.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "512"
}

variable "hms_nofile_ulimit" {
  description = "Ulimit for the Hive Metastore container."
  type        = "string"
  default     = "32768"
}

variable "hms_docker_image" {
  description = "Docker image ID for the Hive Metastore."
  type        = "string"
}

variable "hms_docker_version" {
  description = "Version of the Docker image for the Hive Metastore."
  type        = "string"
}

variable "hms_rw_ecs_task_count" {
  description = "Desired ECS task count of the read/write Hive Metastore service."
  type        = "string"
  default     = "2"
}

variable "hms_ro_ecs_task_count" {
  description = "Desired ECS task count of the read only Hive Metastore service."
  type        = "string"
  default     = "2"
}

variable "elb_timeout" {
  description = "Idle timeout for Apiary ELB."
  type        = "string"
  default     = "1800"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress CIDR list."
  type        = "list"
}

variable "enable_gluesync" {
  description = "Enable metadata sync from Hive to the Glue catalog."
  type        = "string"
  default     = ""
}

variable "enable_metadata_events" {
  description = "Enable Hive Metastore SNS listener."
  type        = "string"
  default     = ""
}

variable "enable_data_events" {
  description = "Enable managed buckets S3 event notifications."
  type        = "string"
  default     = ""
}

variable "enable_s3_paid_metrics" {
  description = "Enable managed S3 buckets request and data transfer metrics."
  type        = "string"
  default     = ""
}

variable "ranger_policy_manager_url" {
  description = "Ranger admin URL to synchronize policies."
  type        = "string"
  default     = ""
}

variable "ranger_audit_solr_url" {
  description = "Ranger Solr audit provider configuration."
  type        = "string"
  default     = ""
}

variable "ranger_audit_db_url" {
  description = "Ranger DB audit provider configuration."
  type        = "string"
  default     = ""
}

variable "ranger_audit_secret_name" {
  description = "Ranger DB audit secret name."
  type        = "string"
  default     = ""
}

variable "ldap_url" {
  description = "Active directory LDAP URL to configure Hadoop LDAP group mapping."
  type        = "string"
  default     = ""
}

variable "ldap_ca_cert" {
  description = "Base64 encoded Certificate Authority bundle to validate LDAPS connections."
  type        = "string"
  default     = ""
}

variable "ldap_base" {
  description = "Active directory LDAP base DN to search users and groups."
  type        = "string"
  default     = ""
}

variable "ldap_secret_name" {
  description = "Active directory LDAP bind DN SecretsManager secret name."
  type        = "string"
  default     = ""
}

variable "secondary_vpcs" {
  description = "List of VPCs to associate with Service Discovery namespace"
  type        = "list"
  default     = []
}
