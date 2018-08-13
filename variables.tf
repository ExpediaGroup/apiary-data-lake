/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "instance_name" {
  description = "Apiary instance name to identify resources in multi instance deployments"
  type        = "string"
  default     = ""
}

variable "apiary_tags" {
  description = "Common tags that get put on all resources"
  type        = "map"
}

variable "vault_addr" {
  description = "Address of vault server for secrets"
  type        = "string"
}

variable "vault_internal_addr" {
  description = "Address of vault server for secrets"
  type        = "string"
}

variable "vault_path" {
  description = "Path to apiary secrets in vault"
  type        = "string"
  default     = ""
}

variable "apiary_domain_name" {
  description = "Apiary domain name for route 53"
  type        = "string"
  default     = ""
}

variable "vpc_id" {
  description = "VPC id"
  type        = "string"
}

variable "private_subnets" {
  description = "private subnets"
  type        = "list"
}

variable "aws_region" {
  description = "aws region"
  type        = "string"
}

variable "apiary_log_bucket" {
  description = "bucket for apiary logs"
  type        = "string"
}

variable "apiary_log_prefix" {
  description = "prefix for apiary logs"
  type        = "string"
  default     = ""
}

variable "apiary_managed_schemas" {
  description = "schema names from which s3 bucket names will be derived,corresponding s3 bucket will be named as apiary_instance-aws_account-aws_region-schema_name"
  type        = "list"
  default     = []
}

variable "external_data_buckets" {
  description = "buckets that are not managed by apiary,but added to hive metastore IAM role access"
  type        = "list"
  default     = []
}

variable "apiary_customer_accounts" {
  description = "aws account ids for clients of this metastore"
  type        = "list"
}

variable "apiary_producer_iamroles" {
  description = "aws iam roles allowed write access to managed apiary s3 buckets"
  type        = "map"
  default     = {}
}

variable "apiary_rds_additional_sg" {
  description = "Comma-seperated string for additional security groups to attach to RDS"
  type        = "list"
  default     = []
}

variable "apiary_database_name" {
  description = "Database name to create in RDS for Apiary"
  type        = "string"
  default     = "apiary"
}

variable "db_instance_class" {
  description = "instance type for the rds metastore"
  type        = "string"
}

variable "db_instance_count" {
  description = "desired count of database cluster instances"
  type        = "string"
  default     = "2"
}

variable "db_backup_retention" {
  description = "The days to retain backups for, for the rds metastore."
  type        = "string"
}

variable "db_backup_window" {
  description = "preferred backup window for rds metastore database in UTC."
  type        = "string"
  default     = "02:00-03:00"
}

variable "db_maintenance_window" {
  description = "preferred maintenance window for rds metastore database in UTC."
  type        = "string"
  default     = "wed:03:00-wed:04:00"
}

variable "hms_log_level" {
  description = "log level for the hive metastore"
  type        = "string"
  default     = "INFO"
}

variable "hms_ro_heapsize" {
  description = "heapsize for the RO hive metastore."
  type        = "string"
}

variable "hms_rw_heapsize" {
  description = "heapsize for the RW hive metastore."
  type        = "string"
}

variable "hms_nofile_ulimit" {
  description = "ulimit for the metastore container"
  type        = "string"
  default     = "32768"
}

variable "hms_docker_image" {
  description = "docker image id for the hive metastore"
  type        = "string"
}

variable "hms_docker_version" {
  description = "version of the docker image for the hive metastore"
  type        = "string"
}

variable "hms_readwrite_instance_count" {
  description = "desired count of the RW hive metastore service"
  type        = "string"
  default     = "2"
}

variable "hms_readonly_instance_count" {
  description = "desired count of the RO hive metastore service"
  type        = "string"
  default     = "2"
}

variable "apiary_s3_alarm_threshold" {
  description = "will trigger cloudwatch alarm if s3 is greater than this, default 1TB"
  type        = "string"
  default     = "10000000000000"
}

variable "elb_timeout" {
  description = "idle timeout for apiary ELB"
  type        = "string"
  default     = "1800"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress cidr list"
  type        = "list"
}

variable "enable_gluesync" {
  description = "enable metadata sync from hive to glue catalog"
  type        = "string"
  default     = ""
}

variable "enable_metadata_events" {
  description = "enable hive metastore sns listener"
  type        = "string"
  default     = ""
}

variable "enable_data_events" {
  description = "enable managed buckets s3 event notifications"
  type        = "string"
  default     = ""
}

variable "disable_database_management" {
  description = "disable creating and dropping databases from hive cli"
  type        = "string"
  default     = ""
}

variable "ranger_policy_mgr_url" {
  description = "ranger admin url to synchronize policies"
  type        = "string"
  default     = ""
}

variable "ranger_audit_solr_url" {
  description = "ranger solr audit provider configuration"
  type        = "string"
  default     = ""
}

variable "ldap_url" {
  description = "active directory ldap url to configure hadoop LDAP group mapping"
  type        = "string"
  default     = ""
}

variable "ldap_base" {
  description = "active directory ldap base dn to search users and groups"
  type        = "string"
  default     = ""
}
