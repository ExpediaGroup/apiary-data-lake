# Overview

 This repo contains a Terraform module to deploy the Apiary data lake component. The module deploys various stateful components in a typical Hadoop-compatible data lake in AWS.

For more information please refer to the main [Apiary](https://github.com/ExpediaInc/apiary) project page.

## Architecture
![Datalake  architecture](docs/apiary_datalake_3d.jpg)

## Key Features
  * Highly Available(HA) metastore service - packaged as Docker container and running on an ECS Fargate Cluster.
  * PrivateLinks - Network load balancers and VPC endpoints to enable federated access to read-only and read/write metastores.
  * Managed schemas - integrated way of managing Hive schemas, S3 buckets and bucket policies.
  * SNS Listener - A Hive metastore event listener to publish all metadata updates to a SNS topic, see [ApiarySNSListener](https://github.com/ExpediaInc/apiary-extensions/tree/master/apiary-metastore-listener) for more details.
  * Gluesync  - A metastore event listener to replay Hive metadata events in a Glue catalog.
  * Metastore authorization - A metastore pre-event listener to handle authorization using Ranger.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| apiary_customer_accounts | AWS account ids for clients of this Metastore | list | - | yes |
| apiary_database_name | Database name to create in RDS for Apiary | string | `apiary` | no |
| apiary_domain_name | Apiary domain name for Route53 | string | `` | no |
| apiary_log_bucket | Bucket for Apiary logs | string | - | yes |
| apiary_log_prefix | Prefix for Apiary logs | string | `` | no |
| apiary_managed_schemas | Schema names from which S3 bucket names will be derived,corresponding S3 bucket will be named as apiary_instance-aws_account-aws_region-schema_name | list | `<list>` | no |
| apiary_producer_iamroles | AWS IAM roles allowed write access to managed Apiary S3 buckets | map | `<map>` | no |
| apiary_rds_additional_sg | Comma-seperated string for additional security groups to attach to RDS | list | `<list>` | no |
| apiary_s3_alarm_threshold | Will trigger Cloudwatch alarm if S3 is greater than this, default 1TB | string | `10000000000000` | no |
| apiary_tags | Common tags that get put on all resources | map | - | yes |
| aws_region | AWS region | string | - | yes |
| db_backup_retention | The days to retain backups for, for the RDS Metastore DB | string | - | yes |
| db_backup_window | Preferred backup window for rds Metastore DB in UTC. | string | `02:00-03:00` | no |
| db_instance_class | Instance type for the RDS Metastore DB | string | - | yes |
| db_instance_count | Desired count of database cluster instances | string | `2` | no |
| db_maintenance_window | Preferred maintenance window for RDS Metastore DB in UTC. | string | `wed:03:00-wed:04:00` | no |
| disable_database_management | Disable creating and dropping databases from Hive CLI | string | `` | no |
| ecs_domain_name | Domain name to use for hosted zone created by ECS service discovery | string | `lcl` | no |
| elb_timeout | Idle timeout for Apiary ELB | string | `1800` | no |
| enable_data_events | Enable managed buckets S3 event notifications | string | `` | no |
| enable_gluesync | Enable metadata sync from Hive to Glue catalog | string | `` | no |
| enable_metadata_events | Enable Hive Metastore SNS listener | string | `` | no |
| external_data_buckets | Buckets that are not managed by Apiary,but added to Hive Metastore IAM role access | list | `<list>` | no |
| external_database_host | External metastore database host to support legacy installations, MySQL database won't be created by Apiary when this option is specified | string | `` | no |
| hms_docker_image | Docker image id for the Hive Metastore | string | - | yes |
| hms_docker_version | Version of the Docker image for the Hive Metastore | string | - | yes |
| hms_log_level | Log level for the Hive Metastore | string | `INFO` | no |
| hms_nofile_ulimit | Ulimit for the Hive Metastore container | string | `32768` | no |
| hms_readonly_instance_count | Desired count of the RO Hive Metastore service | string | `2` | no |
| hms_readwrite_instance_count | Desired count of the RW Hive Metastore service | string | `2` | no |
| hms_ro_cpu | CPU for the RO Hive Metastore ECS task. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `512` | no |
| hms_ro_heapsize | Heapsize for the RO Hive Metastore. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | - | yes |
| hms_rw_cpu | CPU for the RW Hive Metastore ECS task. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `512` | no |
| hms_rw_heapsize | Heapsize for the RW Hive Metastore. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | - | yes |
| ingress_cidr | Generally allowed ingress CIDR list | list | - | yes |
| instance_name | Apiary instance name to identify resources in multi instance deployments | string | `` | no |
| ldap_base | Active directory LDAP base DN to search users and groups | string | `` | no |
| ldap_url | Active directory LDAP url to configure Hadoop LDAP group mapping | string | `` | no |
| private_subnets | Private subnets | list | - | yes |
| ranger_audit_db_url | Ranger db audit provider configuration | string | `` | no |
| ranger_audit_solr_url | Ranger solr audit provider configuration | string | `` | no |
| ranger_policy_mgr_url | Ranger admin url to synchronize policies | string | `` | no |
| vault_addr | Address of vault server for secrets | string | - | yes |
| vault_internal_addr | Address of vault server for secrets | string | - | yes |
| vault_login_path | Remote path in Vault where the auth method is enabled." More details: https://www.vaultproject.io/docs/commands/login.html | string | `` | no |
| vault_path | Path to Apiary secrets in Vault | string | `` | no |
| vpc_id | VPC id | string | - | yes |

## Usage

Example module invocation:
```
module "apiary" {
  source        = "git::https://github.com/ExpediaInc/apiary-metastore.git?ref=v1.0.0"
  aws_region    = "us-west-2"
  instance_name = "test"
  apiary_tags   = "${var.tags}"

  private_subnets = [ "subnet1, "subnet2", "subnet3" ]
  vpc_id          = "vpc-123456"

  vault_addr          = "https://vault.internal.domain"
  vault_internal_addr = "https://vault.service.consul:8200"

  hms_docker_image             = "${aws_account}.dkr.ecr.${aws_region}.amazonaws.com/apiary-metastore"
  hms_docker_version           = "1.0.0"
  hms_ro_heapsize              = "8192"
  hms_rw_heapsize              = "8192"

  apiary_log_bucket   = "s3-logs-bucket"
  db_instance_class   = "db.t2.medium"
  db_backup_retention = "7"

  apiary_managed_schemas   = [ "db1", "db2", "dm" ]
  apiary_customer_accounts = [ "aws_account_no_1", "aws_account_no_2"]
  ingress_cidr             = ["10.0.0.0/8"]
}

```

## Notes
  The Apiary metastore Docker image is not yet published to a public repository, you can build from this [repo](https://github.com/ExpediaInc/apiary-metastore-docker) and then publish it to your own ECR.

  The Terraform module and Docker container read various Vault secrets, you can create these using the following commands:
  ```
  vault write secret/apiary-test-us-west-2/db_master_user username=apiary password=xxxxxxxxxxxxxxxxxx
  vault write secret/apiary-test-us-west-2/hive_rouser username=hivero password=xxxxxxxxxxxxxxxxxx
  vault write secret/apiary-test-us-west-2/hive_rwuser username=hiverw password=xxxxxxxxxxxxxxxxxx
  ```

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2018 Expedia Inc.
