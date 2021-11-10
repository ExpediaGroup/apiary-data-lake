# Variables

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apiary\_assume\_roles | Cross account AWS IAM roles allowed write access to managed Apiary S3 buckets using assume policy. | `list(any)` | `[]` | no |
| apiary\_consumer\_iamroles | AWS IAM roles allowed read access to managed Apiary S3 buckets. | `list(string)` | `[]` | no |
| apiary\_customer\_accounts | AWS account IDs for clients of this Metastore. | `list(string)` | `[]` | no |
| apiary\_customer\_condition | IAM policy condition applied to customer account s3 object access. | `string` | `""` | no |
| apiary\_database\_name | Database name to create in RDS for Apiary. | `string` | `"apiary"` | no |
| apiary\_deny\_iamrole\_actions | List of S3 actions that 'apiary\_deny\_iamroles' are not allowed to perform. | `list(string)` | <pre>[<br>  "s3:Abort*",<br>  "s3:Bypass*",<br>  "s3:Delete*",<br>  "s3:GetObject",<br>  "s3:GetObjectTorrent",<br>  "s3:GetObjectVersion",<br>  "s3:GetObjectVersionTorrent",<br>  "s3:ObjectOwnerOverrideToBucketOwner",<br>  "s3:Put*",<br>  "s3:Replicate*",<br>  "s3:Restore*"<br>]</pre> | no |
| apiary\_deny\_iamroles | AWS IAM roles denied access to Apiary managed S3 buckets. | `list(string)` | `[]` | no |
| apiary\_domain\_name | Apiary domain name for Route 53. | `string` | `""` | no |
| apiary\_log\_bucket | Bucket for Apiary logs.If this is blank, module will create a bucket. | `string` | `""` | no |
| apiary\_log\_prefix | Prefix for Apiary logs. | `string` | `""` | no |
| apiary\_managed\_schemas | List of maps, each map contains schema name from which S3 bucket names will be derived, and various properties. The corresponding S3 bucket will be named as apiary\_instance-aws\_account-aws\_region-schema\_name. | `list(map(string))` | `[]` | no |
| apiary\_producer\_iamroles | AWS IAM roles allowed write access to managed Apiary S3 buckets. | `map(any)` | `{}` | no |
| apiary\_governance\_iamroles | AWS IAM governance roles allowed read and tagging access to managed Apiary S3 buckets. | `list(string)` | `[]` | no |
| apiary\_rds\_additional\_sg | Comma-separated string containing additional security groups to attach to RDS. | `list(any)` | `[]` | no |
| apiary\_shared\_schemas | Schema names which are accessible from read-only metastore, default is all schemas. | `list(any)` | `[]` | no |
| apiary\_tags | Common tags that get put on all resources. | `map(any)` | n/a | yes |
| atlas\_cluster\_name | Name of the Atlas cluster where metastore plugin will send DDL events.  Defaults to `var.instance_name` if not set. | `string` | `""` | no |
| atlas\_kafka\_bootstrap\_servers | Kafka instance url. | `string` | `""` | no |
| aws\_region | AWS region. | `string` | n/a | yes |
| dashboard\_namespace | k8s namespace to deploy grafana dashboard. | `string` | `"monitoring"` | no |
| db\_apply\_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. | `bool` | `false` | no |
| db\_backup\_retention | The number of days to retain backups for the RDS Metastore DB. | `string` | n/a | yes |
| db\_backup\_window | Preferred backup window for the RDS Metastore DB in UTC. | `string` | `"02:00-03:00"` | no |
| db\_instance\_class | Instance type for the RDS Metastore DB. | `string` | n/a | yes |
| db\_instance\_count | Desired count of database cluster instances. | `string` | `"2"` | no |
| db\_maintenance\_window | Preferred maintenance window for the RDS Metastore DB in UTC. | `string` | `"wed:03:00-wed:04:00"` | no |
| db\_master\_username | Aurora cluster MySQL master user name. | `string` | `"apiary"` | no |
| db\_ro\_secret\_name | Aurora cluster MySQL read-only user SecretsManger secret name. | `string` | `""` | no |
| db\_rw\_secret\_name | Aurora cluster MySQL read/write user SecretsManager secret name. | `string` | `""` | no |
| disallow\_incompatible\_col\_type\_changes | Hive metastore setting to disallow validation when incompatible schema type changes. | `bool` | `true` | no |
| docker\_registry\_auth\_secret\_name | Docker Registry authentication SecretManager secret name. | `string` | `""` | no |
| ecs\_domain\_extension | Domain name to use for hosted zone created by ECS service discovery. | `string` | `"lcl"` | no |
| elb\_timeout | Idle timeout for Apiary ELB. | `string` | `"1800"` | no |
| enable\_apiary\_s3\_log\_hive | Create hive database to archive s3 logs in parquet format.Only applicable when module manages logs S3 bucket. | `bool` | `true` | no |
| enable\_data\_events | Enable managed buckets S3 event notifications. | `bool` | `false` | no |
| enable\_gluesync | Enable metadata sync from Hive to the Glue catalog. | `bool` | `false` | no |
| enable\_hive\_metastore\_metrics | Enable sending Hive Metastore metrics to CloudWatch. | `bool` | `false` | no |
| enable\_metadata\_events | Enable Hive Metastore SNS listener. | `bool` | `false` | no |
| enable\_s3\_paid\_metrics | Enable managed S3 buckets request and data transfer metrics. | `bool` | `false` | no |
| enable\_vpc\_endpoint\_services | Enable metastore NLB, Route53 entries VPC access and VPC endpoint services, for cross-account access. | `bool` | `true` | no |
| encrypt\_db | Specifies whether the DB cluster is encrypted | `bool` | `false` | no |
| external\_data\_buckets | Buckets that are not managed by Apiary but added to Hive Metastore IAM role access. | `list(any)` | `[]` | no |
| external\_database\_host | External Metastore database host to support legacy installations, MySQL database won't be created by Apiary when this option is specified. | `string` | `""` | no |
| hive\_metastore\_port | Port on which both Hive Metastore readwrite and readonly will run. | `number` | `9083` | no |
| hms\_docker\_image | Docker image ID for the Hive Metastore. | `string` | n/a | yes |
| hms\_docker\_version | Version of the Docker image for the Hive Metastore. | `string` | n/a | yes |
| hms\_instance\_type | Hive Metastore instance type, possible values: ecs,k8s. | `string` | `"ecs"` | no |
| hms\_log\_level | Log level for the Hive Metastore. | `string` | `"INFO"` | no |
| hms\_nofile\_ulimit | Ulimit for the Hive Metastore container. | `string` | `"32768"` | no |
| hms\_ro\_cpu | CPU for the read only Hive Metastore ECS task.<br>Valid values can be 256, 512, 1024, 2048 and 4096.<br>Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `string` | `"512"` | no |
| hms\_ro\_ecs\_task\_count | Desired ECS task count of the read only Hive Metastore service. | `string` | `"3"` | no |
| hms\_ro\_heapsize | Heapsize for the read only Hive Metastore.<br>Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `string` | `"2048"` | no |
| hms\_rw\_cpu | CPU for the read/write Hive Metastore ECS task.<br>Valid values can be 256, 512, 1024, 2048 and 4096.<br>Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `string` | `"512"` | no |
| hms\_rw\_ecs\_task\_count | Desired ECS task count of the read/write Hive Metastore service. | `string` | `"3"` | no |
| hms\_rw\_heapsize | Heapsize for the read/write Hive Metastore.<br>Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `string` | `"2048"` | no |
| iam\_name\_root | Name to identify Hive Metastore IAM roles. | `string` | `"hms"` | no |
| ingress\_cidr | Generally allowed ingress CIDR list. | `list(string)` | n/a | yes |
| instance\_name | Apiary instance name to identify resources in multi-instance deployments. | `string` | `""` | no |
| k8s\_docker\_registry\_secret | Docker Registry authentication K8s secret name. | `string` | `""` | no |
| kafka\_bootstrap\_servers | Kafka bootstrap servers to send metastore events, setting this enables Hive Metastore Kafka listener. | `string` | `""` | no |
| kafka\_topic\_name | Kafka topic to send metastore events. | `string` | `""` | no |
| kiam\_arn | Kiam server IAM role ARN. | `string` | `""` | no |
| ldap\_base | Active directory LDAP base DN to search users and groups. | `string` | `""` | no |
| ldap\_ca\_cert | Base64 encoded Certificate Authority bundle to validate LDAPS connections. | `string` | `""` | no |
| ldap\_secret\_name | Active directory LDAP bind DN SecretsManager secret name. | `string` | `""` | no |
| ldap\_url | Active directory LDAP URL to configure Hadoop LDAP group mapping. | `string` | `""` | no |
| metastore\_namespace | k8s namespace to deploy metastore containers. | `string` | `"metastore"` | no |
| oidc\_provider | EKS cluster OIDC provider name, required for configuring IAM using IRSA. | `string` | `""` | no |
| private\_subnets | Private subnets. | `list(any)` | n/a | yes |
| ranger\_audit\_db\_url | Ranger DB audit provider configuration. | `string` | `""` | no |
| ranger\_audit\_secret\_name | Ranger DB audit secret name. | `string` | `""` | no |
| ranger\_audit\_solr\_url | Ranger Solr audit provider configuration. | `string` | `""` | no |
| ranger\_policy\_manager\_url | Ranger admin URL to synchronize policies. | `string` | `""` | no |
| rds\_max\_allowed\_packet | RDS/MySQL setting for parameter 'max\_allowed\_packet' in bytes. Default is 128MB (Note that MySQL default is 4MB). | `number` | `134217728` | no |
| rw\_ingress\_cidr | Read-Write metastore ingress CIDR list. If not set, defaults to `var.ingress_cidr`. | `list(string)` | `[]` | no |
| s3\_enable\_inventory | Enable S3 inventory configuration. | `bool` | `false` | no |
| s3\_inventory\_customer\_accounts | AWS account IDs allowed to access s3 inventory database. | `list(string)` | `[]` | no |
| s3\_inventory\_format | Output format for S3 inventory results. Can be Parquet, ORC, CSV | `string` | `"ORC"` | no |
| s3\_inventory\_update\_schedule | Cron schedule to update S3 inventory tables (if enabled). Defaults to every 12 hours. | `string` | `"0 */12 * * *"` | no |
| s3\_lifecycle\_abort\_incomplete\_multipart\_upload\_days | Number of days after which incomplete multipart uploads will be deleted. | `string` | `"7"` | no |
| s3\_lifecycle\_policy\_transition\_period | S3 Lifecycle Policy number of days for Transition rule | `string` | `"30"` | no |
| s3\_log\_expiry | Number of days after which Apiary S3 bucket logs expire. | `string` | `"365"` | no |
| s3\_logs\_sqs\_delay\_seconds | The time in seconds that the delivery of all messages in the queue will be delayed. | `number` | `300` | no |
| s3\_logs\_sqs\_message\_retention\_seconds | Time in seconds after which message will be deleted from the queue. | `number` | `345600` | no |
| s3\_logs\_sqs\_receive\_wait\_time\_seconds | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. | `number` | `10` | no |
| s3\_logs\_sqs\_visibility\_timeout\_seconds | Time in seconds after which message will be returned to the queue if it is not deleted. | `number` | `3600` | no |
| s3\_storage\_class | S3 storage class after transition using lifecycle policy | `string` | `"INTELLIGENT_TIERING"` | no |
| secondary\_vpcs | List of VPCs to associate with Service Discovery namespace. | `list(any)` | `[]` | no |
| system\_schema\_customer\_accounts | AWS account IDs allowed to access system database. | `list(string)` | `[]` | no |
| system\_schema\_name | Name for the internal system database | `string` | `"apiary_system"` | no |
| table\_param\_filter | A regular expression for selecting necessary table parameters for the SNS listener. If the value isn't set, then no table parameters are selected. | `string` | `""` | no |
| vpc\_id | VPC ID. | `string` | n/a | yes |

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
   encryption   = "aws:kms" //supported values for encryption are AES256,aws:kms
   admin_roles = "role1_arn,role2_arn" //kms key management will be restricted to these roles.
   client_roles = "role3_arn,role4_arn" //s3 bucket read/write and kms key usage will be restricted to these roles.
   customer_accounts = "account_id1,account_id2" //this will override module level apiary_customer_accounts
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
| encryption | S3 objects encryption type, supported values are AES256,aws:kms. | string | null | no |
| admin_roles | IAM roles configured with admin access on corresponding KMS keys,required when encryption type is `aws:kms`. | string | null | no |
| client_roles | IAM roles configured with usage access on corresponding KMS keys,required when encryption type is `aws:kms`. | string | null | no |
