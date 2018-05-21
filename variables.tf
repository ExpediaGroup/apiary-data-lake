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

variable "apiary_asg_tags" {
  description = "Tags that are added to the ecs autoscaling group."
  type        = "list"
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

variable "aws_keyname" {
  description = "aws keypair name for logging into ec2 instances and ecs clusters"
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

variable "apiary_data_buckets" {
  description = "buckets that apiary can serve data from"
  type        = "list"
}

variable "apiary_customer_accounts" {
  description = "aws account ids for clients of this metastore"
  type        = "list"
}

variable "db_instance_class" {
  description = "instance type for the rds metastore"
  type        = "string"
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

variable "ecs_instance_type" {
  description = "instance type for the ecs cluster"
  type        = "string"
  default     = "t2.large"
}

variable "ecs_asg_max_size" {
  description = "max size of the ecs cluster"
  type        = "string"
  default     = "5"
}

variable "hms_readwrite_instance_count" {
  description = "desired count of the RW hive metastore service"
  type        = "string"
}

variable "hms_readonly_instance_count" {
  description = "desired count of the RO hive metastore service"
  type        = "string"
}

variable "apiary_s3_alarm_threshold" {
  description = "will trigger cloudwatch alarm if s3 is greater than this, default 1TB"
  type        = "string"
  default     = "10000000000000"
}

variable "apiary_db_alarm_threshold" {
  description = "will trigger cloudwatch alarm if db free space is less than, default 10G"
  type        = "string"
  default     = "10000000000"
}

variable elb_timeout {
  description = "idle timeout for apiary ELB"
  type        = "string"
  default     = "1800"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress cidr list"
  type        = "list"
}
