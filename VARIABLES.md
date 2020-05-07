# Variables

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| apiary_assume_roles | List of maps - each map describes an IAM role that can be assumed in this account to write data into the configured list of schemas. See section [`apiary_assume_roles`](#apiary_assume_roles) for more info. | list(map) | - | no |
| apiary_customer_accounts | AWS account IDs for clients of this Metastore. | list | - | yes |
| apiary_database_name | Database name to create in RDS for Apiary. | string | `apiary` | no |
| apiary_domain_name | Apiary domain name for Route 53. | string | `` | no |
| apiary_log_bucket | Bucket for Apiary logs. | string | - | yes |
| apiary_log_prefix | Prefix for Apiary logs. | string | `` | no |
| apiary_logs_retention_days | Log retention in days for the Apiary ECS cloudwatch log group. | string | `30` | no |
| apiary_managed_schemas | List of maps - each map entry describes an Apiary schema, along with S3 storage properties for the schema. See section [`apiary_managed_schemas`](#apiary_managed_schemas) for more info. | list(map) | - | no |
| apiary_producer_iamroles | AWS IAM roles allowed write access to managed Apiary S3 buckets. | map | `<map>` | no |
| apiary_rds_additional_sg | Comma-separated string containing additional security groups to attach to RDS. | list | `<list>` | no |
| apiary_shared_schemas | Schema names which are accessible from read-only metastore, default is all schemas. | list | `<list>` | no |
| apiary_tags | Common tags that get put on all resources. | map | - | yes |
| atlas_kafka_bootstrap_servers | Atlas kafka bootstrap servers. | string | `` | no |
| atlas_cluster_name | Name of the Atlas cluster where metastore plugin will send DDL events.  Defaults to `var.instance_name` if not set. | string | `` | no |
| aws_region | AWS region. | string | - | yes |
| db_apply_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. | bool | `false` | no |
| db_backup_retention | The number of days to retain backups for the RDS Metastore DB. | string | - | yes |
| db_backup_window | Preferred backup window for the RDS Metastore DB in UTC. | string | `02:00-03:00` | no |
| db_instance_class | Instance type for the RDS Metastore DB. | string | - | yes |
| db_instance_count | Desired count of database cluster instances. | string | `2` | no |
| db_maintenance_window | Preferred maintenance window for the RDS Metastore DB in UTC. | string | `wed:03:00-wed:04:00` | no |
| db_master_username | Aurora cluster MySQL master user name. | string | `apiary` | no |
| db_ro_secret_name | Aurora cluster MySQL read-only user SecretsManger secret name. | string | `` | no |
| db_rw_secret_name | Aurora cluster MySQL read/write user SecretsManager secret name. | string | `` | no |
| docker_registry_auth_secret_name | Docker Registry authentication SecretManager secret name. | string | `` | no |
| ecs_domain_extension | Domain name to use for hosted zone created by ECS service discovery. | string | `lcl` | no |
| elb_timeout | Idle timeout for Apiary ELB. | string | `1800` | no |
| enable_data_events | Enable managed buckets S3 event notifications. | bool | `false` | no |
| enable_gluesync | Enable metadata sync from Hive to the Glue catalog. | bool | `false` | no |
| enable_hive_metastore_metrics | Enable sending Hive Metastore metrics to CloudWatch. | bool | `false` | no |
| enable_metadata_events | Enable Hive Metastore SNS listener. | bool | `false` | no |
| enable_s3_paid_metrics | Enable managed S3 buckets request and data transfer metrics. | bool | `false` | no |
| external_data_buckets | Buckets that are not managed by Apiary but added to Hive Metastore IAM role access. | list | `<list>` | no |
| external_database_host | External Metastore database host to support legacy installations, MySQL database won't be created by Apiary when this option is specified. | string | `` | no |
| hms_docker_image | Docker image ID for the Hive Metastore. | string | - | yes |
| hms_docker_version | Version of the Docker image for the Hive Metastore. | string | - | yes |
| hms_instance_type | Hive Metastore instance type, possible values ecs, k8s. | string | ecs | no |
| hms_log_level | Log level for the Hive Metastore. | string | `INFO` | no |
| hms_nofile_ulimit | Ulimit for the Hive Metastore container. | string | `32768` | no |
| hms_ro_cpu | CPU for the read only Hive Metastore ECS task. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `512` | no |
| hms_ro_ecs_task_count | Desired ECS task count of the read only Hive Metastore service. | string | `3` | no |
| hms_ro_heapsize | Heapsize for the read only Hive Metastore. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | - | yes |
| hms_rw_cpu | CPU for the read/write Hive Metastore ECS task. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `512` | no |
| hms_rw_ecs_task_count | Desired ECS task count of the read/write Hive Metastore service. | string | `3` | no |
| hms_rw_heapsize | Heapsize for the read/write Hive Metastore. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | - | yes |
| iam_name_root | Name to identify Hive Metastore IAM roles. | string | `hms` | no |
| ingress_cidr | Generally allowed ingress CIDR list. | list | - | yes |
| instance_name | Apiary instance name to identify resources in multi-instance deployments. | string | `` | no |
| k8s_docker_registry_secret| Docker Registry authentication K8s secret name. | string | `` | no |
| kiam_arn | Kiam server IAM role ARN. | string | `` | no |
| ldap_base | Active directory LDAP base DN to search users and groups. | string | `` | no |
| ldap_ca_cert | Base64 encoded Certificate Authority bundle to validate LDAPS connections. | string | `` | no |
| ldap_secret_name | Active directory LDAP bind DN SecretsManager secret name. | string | `` | no |
| ldap_url | Active directory LDAP URL to configure Hadoop LDAP group mapping. | string | `` | no |
| private_subnets | Private subnets. | list | - | yes |
| ranger_audit_db_url | Ranger DB audit provider configuration. | string | `` | no |
| ranger_audit_secret_name | Ranger DB audit secret name. | string | `` | no |
| ranger_audit_solr_url | Ranger Solr audit provider configuration. | string | `` | no |
| ranger_policy_manager_url | Ranger admin URL to synchronize policies. | string | `` | no |
| s3_enable_inventory | Enable S3 inventory configuration. | bool | `false` | no |
| s3_inventory_format | Output format for S3 inventory results. Can be Parquet, ORC, CSV | string | `ORC` | no |
| s3_inventory_update_schedule | Cron schedule to update S3 inventory tables (if enabled). Defaults to every 12 hours. | string | `0 */12 * * *` | no |
| s3_lifecycle_policy_transition_period | Number of days for transition to a different storage class using lifecycle policy. | string  | `30` | no |
| s3_lifecycle_abort_incomplete_multipart_upload_days | Number of days after which incomplete multipart uploads will be deleted. | string  | `7` | no |
| s3_storage_class | Destination S3 storage class for transition in the lifecycle policy. | string  | `INTELLIGENT_TIERING` | no |
| secondary_vpcs | List of VPCs to associate with Service Discovery namespace. | list | `<list>` | no |
| table_param_filter | A regular expression for selecting necessary table parameters for the SNS listener. If the value isn't set, then no table parameters are selected. | string | `` | no |
| vpc_id | VPC ID. | string | - | yes |

### apiary_assume_roles

A list of maps.  Each map entry describes a role that is created in this account, and a list of principals (IAM ARNs) in other accounts that are allowed  
to assume this role.  Each entry also specifies a list of Apiary schemas that this role is allowed to write to.

An example entry looks like:
```
apiary_assume_roles = [
  {
    name = "client_name"
    principals = [ "arn:aws:iam::account_number:role/cross-account-role" ]
    schema_names = [ "dm","lz","test_1" ]
    max_role_session_duration_seconds = "7200",
    allow_cross_region_access = true 
  }
]
``` 
`apiary_assume_roles` map entry fields:

Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Short name of the IAM role to be created.  Full name will be `apiary-<name>-<region>`. | string | - | yes |
| principals | List of IAM role ARNs from other accounts that can assume this role. | list(string) | - | yes |
| schema_names | List of Apiary schemas that this role can read/write. | list(string) | - | yes |
| max_role_session_duration_seconds | Number of seconds that the assumed credentials are valid for.| string | `"3600"` | no |
| allow_cross_region_access | If `true`, will allow this role to write these Apiary schemas in all AWS regions that these schemas exist in (in this account). If `false`, can only write in this region. | bool | `false` | no |


### apiary_managed_schemas

A list of maps. Schema names from which S3 bucket names will be derived, corresponding S3 bucket will be named as apiary_instance-aws_account-aws_region-schema_name, along with S3 storage properties like storage class and number of days for transitions.

An example entry looks like:
```
apiary_managed_schemas = [
  {
   schema_name = "sandbox"
   s3_lifecycle_policy_transition_period = "30"
   s3_storage_class = "INTELLIGENT_TIERING"
   s3_object_expiration_days = 60
   tags=jsonencode({ Domain = "search", ComponentInfo = "1234" })
   enable_data_events_sqs = "1"
  }
]
```
`apiary_managed_schemas` map entry fields:

Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| schema_name | Name of the S3 bucket. Full name will be `apiary_instance-aws_account-aws_region-schema_name`. | string | - | yes |
| enable_data_events_sqs | If set to `"1"`, S3 data event notifications for `ObjectCreated` and `ObjectRemoved` will be sent to an SQS queue for processing by external systems. | string | - | no |
| s3_lifecycle_policy_transition_period | Number of days for transition to a different storage class using lifecycle policy. | string | "30" | No |
| s3_storage_class | Destination S3 storage class for transition in the lifecycle policy. For valid values for S3 Storage classes, reference: https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#storage_class | string | "INTELLIGENT_TIERING" | No |
| s3_object_expiration_days | Number of days after which objects in Apiary managed schema buckets expire. | number | null | No |
| tags | Additional tags added to the S3 data bucket. The map of tags must be encoded as a string using `jsonencode` (see sample above). If the `var.apiary_tags` collection and the tags passed to `apiary_managed_schemas` both contain the same tag name, the tag value passed to `apiary_managed_schemas` will be used. | string | null | no |
