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

variable "apiary_domain_private_zone" {
  description = "Apiary domain zone private"
  type        = bool
  default     = true
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

variable "hive_metastore_port" {
  description = "Port on which both Hive Metastore readwrite and readonly will run."
  type        = number
  default     = 9083
}

variable "apiary_log_bucket" {
  description = "Bucket for Apiary logs.If this is blank, module will create a bucket."
  type        = string
  default     = ""
}

variable "apiary_log_prefix" {
  description = "Prefix for Apiary logs."
  type        = string
  default     = ""
}

variable "enable_apiary_s3_log_hive" {
  description = "Create hive database to archive s3 logs in parquet format.Only applicable when module manages logs S3 bucket."
  type        = bool
  default     = true
}

variable "s3_logs_sqs_visibility_timeout_seconds" {
  description = "Time in seconds after which message will be returned to the queue if it is not deleted."
  type        = number
  default     = 3600
}

variable "s3_logs_sqs_message_retention_seconds" {
  description = "Time in seconds after which message will be deleted from the queue."
  type        = number
  default     = 345600
}

variable "s3_logs_sqs_delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed."
  type        = number
  default     = 300
}

variable "s3_logs_sqs_receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning."
  type        = number
  default     = 10
}

variable "enable_hive_metastore_metrics" {
  description = "Enable sending Hive Metastore metrics to CloudWatch."
  type        = bool
  default     = false
}

variable "enable_hms_housekeeper" {
  description = "Enable HMS lock house keeper. When enabled, this creates a new HMS instance for housekeeping."
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
  type        = list(map(string))
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

variable "enable_vpc_endpoint_services" {
  description = "Enable metastore NLB, Route53 entries VPC access and VPC endpoint services, for cross-account access."
  type        = bool
  default     = true
}

variable "apiary_customer_accounts" {
  description = "AWS account IDs for clients of this Metastore."
  type        = list(string)
  default     = []
}

variable "apiary_customer_condition" {
  description = "IAM policy condition applied to customer account for s3 object access."
  type        = string
  default     = ""
}

variable "apiary_deny_iamroles" {
  description = "AWS IAM roles denied access to Apiary managed S3 buckets."
  type        = list(string)
  default     = []
}

variable "apiary_deny_iamrole_actions" {
  description = "List of S3 actions that 'apiary_deny_iamroles' are not allowed to perform."
  type        = list(string)
  default = [
    "s3:Abort*",
    "s3:Bypass*",
    "s3:Delete*",
    "s3:GetObject",
    "s3:GetObjectTorrent",
    "s3:GetObjectVersion",
    "s3:GetObjectVersionTorrent",
    "s3:ObjectOwnerOverrideToBucketOwner",
    "s3:Put*",
    "s3:Replicate*",
    "s3:Restore*"
  ]
}

variable "apiary_assume_roles" {
  description = "Cross account AWS IAM roles allowed write access to managed Apiary S3 buckets using assume policy."
  type        = list(any)
  default     = []
}

variable "apiary_consumer_iamroles" {
  description = "AWS IAM roles allowed unrestricted read access to managed Apiary S3 buckets."
  type        = list(string)
  default     = []
}

variable "apiary_conditional_consumer_iamroles" {
  description = "AWS IAM roles allowed conditional read access based on apiary_customer_condition to managed Apiary S3 buckets."
  type        = list(string)
  default     = []
}

variable "apiary_consumer_prefix_iamroles" {
  description = "AWS IAM roles allowed unrestricted read access to certain prefixes in managed Apiary S3 buckets."
  type        = map(map(list(string)))
  default     = {}
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

variable "db_copy_tags_to_snapshot" {
  description = "Copy all Cluster tags to snapshots."
  type        = bool
  default     = true
}

variable "encrypt_db" {
  description = "Specifies whether the DB cluster is encrypted"
  type        = bool
  default     = false
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

variable "hms_rw_k8s_replica_count" {
  description = "Initial Number of read/write Hive Metastore k8s pod replicas to create."
  type        = number
  default     = 3
}

variable "hms_ro_k8s_replica_count" {
  description = "Initial Number of read only Hive Metastore k8s pod replicas to create."
  type        = number
  default     = 3
}

variable "hms_ro_k8s_max_replica_count" {
  description = "Max Number of read only Hive Metastore k8s pod replicas to create."
  type        = number
  default     = 10
}

variable "enable_autoscaling" {
  description = "Enable read only Hive Metastore k8s horizontal pod autoscaling"
  type        = bool
  default     = false
}

variable "hms_ro_target_cpu_percentage" {
  description = "Read only Hive Metastore autoscaling threshold for CPU target usage."
  type        = number
  default     = 60
}

variable "elb_timeout" {
  description = "Idle timeout for Apiary ELB."
  type        = string
  default     = "1800"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress CIDR list."
  type        = list(string)
}

variable "rw_ingress_cidr" {
  description = "Read-Write metastore ingress CIDR list. If not set, defaults to `var.ingress_cidr`."
  type        = list(string)
  default     = []
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

variable "s3_enable_inventory_tables" {
  description = "Enable s3 inventory tables and cronjob"
  type        = bool
  default     = true
}

variable "s3_inventory_format" {
  description = "Output format for S3 inventory results. Can be Parquet, ORC, CSV"
  type        = string
  default     = "ORC"
}

variable "s3_inventory_customer_accounts" {
  description = "AWS account IDs allowed to access s3 inventory database."
  type        = list(string)
  default     = []
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

variable "dashboard_namespace" {
  description = "k8s namespace to deploy grafana dashboard."
  default     = "monitoring"
}

variable "metastore_namespace" {
  description = "k8s namespace to deploy metastore containers."
  default     = "metastore"
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

variable "oidc_provider" {
  description = "EKS cluster OIDC provider name, required for configuring IAM using IRSA."
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

variable "system_schema_name" {
  description = "Name for the internal system database"
  type        = string
  default     = "apiary_system"
}

variable "system_schema_customer_accounts" {
  description = "AWS account IDs allowed to access system database."
  type        = list(string)
  default     = []
}


variable "rds_max_allowed_packet" {
  description = "RDS/MySQL setting for parameter 'max_allowed_packet' in bytes. Default is 128MB (Note that MySQL default is 4MB)."
  type        = number
  default     = 134217728
}

variable "disallow_incompatible_col_type_changes" {
  description = "Hive metastore setting to disallow validation when incompatible schema type changes."
  type        = bool
  default     = true
}

variable "apiary_governance_iamroles" {
  description = "AWS IAM governance roles allowed read and tagging access to managed Apiary S3 buckets."
  type        = list(string)
  default     = []
}

variable "enable_dashboard" {
  description = "make EKS & ECS dashboard optional"
  type        = bool
  default     = true
}

variable "rds_family" {
  description = "RDS family"
  type        = string
  default     = "aurora-mysql5.7"
}

variable "rds_engine" {
  description = "RDS engine version"
  type        = string
  default     = "aurora-mysql"
}

variable "hms_autogather_stats" {
  description = "Read-write Hive metastore setting to enable/disable statistics auto-gather on table/partition creation."
  type        = bool
  default     = true
}

variable "hms_ro_db_connection_pool_size" {
  description = "Read-only Hive metastore setting for max size of the MySQL connection pool. Default is 10."
  type        = number
  default     = 10
}

variable "hms_rw_db_connection_pool_size" {
  description = "Read-write Hive metastore setting for max size of the MySQL connection pool. Default is 10."
  type        = number
  default     = 10
}

variable "hms_housekeeper_db_connection_pool_size" {
  description = "HMS Housekeeper setting for max size of the MySQL connection pool. Default is 5."
  type        = number
  default     = 5
}

variable "db_enable_performance_insights" {
  description = "Enable RDS Performance Insights"
  type        = bool
  default     = false
}

variable "db_enhanced_monitoring_interval" {
  description = "RDS monitoring interval (in seconds) for enhanced monitoring.  Valid values are 0, 1, 5, 10, 15, 30, 60. Default is 0."
  type        = number
  default     = 0
}

variable "hms_additional_environment_variables" {
  description = "Additional environment variables for Hive metastore."
  type        = map(any)
  default     = {}
}

variable "hms_housekeeper_additional_environment_variables" {
  description = "Additional environment variables for Hive metastore."
  type        = map(any)
  default     = {}
}

variable "datadog_metrics_hms_readwrite_readonly" {
  description = "HMS metrics to be sent to Datadog."
  type        = list(string)
  default = [
    "metrics_classloading_loaded_value",
    "metrics_threads_count_value",
    "metrics_memory_heap_max_value",
    "metrics_init_total_count_tables_value",
    "metrics_init_total_count_dbs_value",
    "metrics_memory_heap_used_value",
    "metrics_init_total_count_partitions_value"
  ]
}

variable "datadog_metrics_enabled" {
  description = "Enable Datadog metrics for HMS"
  type        = bool
  default     = false
}

variable "datadog_metrics_port" {
  description = "Port in which metrics will be send for Datadog"
  type        = string
  default     = "8080"
}

variable "hms_rw_request_partition_limit" {
  description = "Read-write Hive metastore setting for size of the Hive metastore limit of request partitions."
  type        = string
  default     = ""
}

variable "hms_ro_request_partition_limit" {
  description = "Read-Only Hive metastore setting for size of the Hive metastore limit of request partitions."
  type        = string
  default     = ""
}

variable "datadog_key_secret_name" {
  description = "Name of the secret containing the DataDog API key. This needs to be created manually in AWS secrets manager. This is only applicable to ECS deployments."
  type        = string
  default     = ""
}

variable "datadog_agent_version" {
  description = "Version of the Datadog Agent running in the ECS cluster. This is only applicable to ECS deployments."
  type        = string
  default     = "7.50.3-jmx"
}

variable "datadog_agent_enabled" {
  description = "Whether to include the datadog-agent container. This is only applicable to ECS deployments."
  type        = bool
  default     = false
}

variable "apiary_common_producer_iamroles" {
  description = "AWS IAM roles allowed read-write access to managed Apiary S3 buckets."
  type        = list(string)
  default     = []
}

variable "hms_ro_datanucleus_connection_pooling_type" {
  description = "The Datanucleus connection pool type: Valid types are BoneCP, HikariCP, c3p0, dbcp, dbcp2"
  type    = string
  default = "HikariCP"
}

variable "hms_rw_datanucleus_connection_pooling_type" {
  description = "The Datanucleus connection pool type: Valid types are BoneCP, HikariCP, c3p0, dbcp, dbcp2"
  type    = string
  default = "HikariCP"
}

variable "hms_ro_datanucleus_connection_pool_config" {
  description = "A map of env vars supported by Apiary docker image that can configure the chosen Datanucleus connection pool"
  type = map(any)
  default = {}
}

variable "hms_rw_datanucleus_connection_pool_config" {
  description = "A map of env vars supported by Apiary docker image that can configure the chosen Datanucleus connection pool"
  type = map(any)
  default = {}
}

variable "enable_tcp_keepalive" {
  description = "Enable tcp keepalive settings on the hms pods"
  type        = bool
  default     = false
}

variable "tcp_keepalive_time" {
  description = "Sets net.ipv4.tcp_keepalive_time (seconds)."
  type        = number
  default     = 200
}

variable "tcp_keepalive_intvl" {
  description = "Sets net.ipv4.tcp_keepalive_intvl (seconds)."
  type        = number
  default     = 30
}

variable "tcp_keepalive_probes" {
  description = "Sets net.ipv4.tcp_keepalive_probes (number)."
  type        = number
  default     = 2
}
