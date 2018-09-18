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
| apiary_customer_accounts | aws account ids for clients of this metastore | list | - | yes |
| apiary_database_name | Database name to create in RDS for Apiary | string | `apiary` | no |
| apiary_domain_name | Apiary domain name for route 53 | string | `` | no |
| apiary_log_bucket | bucket for apiary logs | string | - | yes |
| apiary_log_prefix | prefix for apiary logs | string | `` | no |
| apiary_managed_schemas | schema names from which s3 bucket names will be derived,corresponding s3 bucket will be named as apiary_instance-aws_account-aws_region-schema_name | list | `<list>` | no |
| apiary_producer_iamroles | aws iam roles allowed write access to managed apiary s3 buckets | map | `<map>` | no |
| apiary_rds_additional_sg | Comma-seperated string for additional security groups to attach to RDS | list | `<list>` | no |
| apiary_s3_alarm_threshold | will trigger cloudwatch alarm if s3 is greater than this, default 1TB | string | `10000000000000` | no |
| apiary_tags | Common tags that get put on all resources | map | - | yes |
| aws_region | aws region | string | - | yes |
| db_backup_retention | The days to retain backups for, for the rds metastore. | string | - | yes |
| db_backup_window | preferred backup window for rds metastore database in UTC. | string | `02:00-03:00` | no |
| db_instance_class | instance type for the rds metastore | string | - | yes |
| db_instance_count | desired count of database cluster instances | string | `2` | no |
| db_maintenance_window | preferred maintenance window for rds metastore database in UTC. | string | `wed:03:00-wed:04:00` | no |
| disable_database_management | disable creating and dropping databases from hive cli | string | `` | no |
| ecs_domain_name | Domain name to use for hosted zone created by ECS service discovery | string | `lcl` | no |
| elb_timeout | idle timeout for apiary ELB | string | `1800` | no |
| enable_data_events | enable managed buckets s3 event notifications | string | `` | no |
| enable_gluesync | enable metadata sync from hive to glue catalog | string | `` | no |
| enable_metadata_events | enable hive metastore sns listener | string | `` | no |
| external_data_buckets | buckets that are not managed by apiary,but added to hive metastore IAM role access | list | `<list>` | no |
| external_database_host | external metastore database host to support legacy installations, mysql database won't be created by apiary when this option is specified | string | `` | no |
| hms_docker_image | docker image id for the hive metastore | string | - | yes |
| hms_docker_version | version of the docker image for the hive metastore | string | - | yes |
| hms_log_level | log level for the hive metastore | string | `INFO` | no |
| hms_nofile_ulimit | ulimit for the metastore container | string | `32768` | no |
| hms_readonly_instance_count | desired count of the RO hive metastore service | string | `2` | no |
| hms_readwrite_instance_count | desired count of the RW hive metastore service | string | `2` | no |
| hms_ro_cpu | CPU for the RO hive metastore ECS task. Valid values cane be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `512` | no |
| hms_ro_heapsize | heapsize for the RO hive metastore. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | - | yes |
| hms_rw_cpu | CPU for the RW hive metastore ECS task. Valid values cane be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `512` | no |
| hms_rw_heapsize | heapsize for the RW hive metastore. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | - | yes |
| ingress_cidr | Generally allowed ingress cidr list | list | - | yes |
| instance_name | Apiary instance name to identify resources in multi instance deployments | string | `` | no |
| ldap_base | active directory ldap base dn to search users and groups | string | `` | no |
| ldap_url | active directory ldap url to configure hadoop LDAP group mapping | string | `` | no |
| private_subnets | private subnets | list | - | yes |
| ranger_audit_db_url | ranger db audit provider configuration | string | `` | no |
| ranger_audit_solr_url | ranger solr audit provider configuration | string | `` | no |
| ranger_policy_mgr_url | ranger admin url to synchronize policies | string | `` | no |
| vault_addr | Address of vault server for secrets | string | - | yes |
| vault_internal_addr | Address of vault server for secrets | string | - | yes |
| vault_login_path | Remote path in Vault where the auth method is enabled." More details: https://www.vaultproject.io/docs/commands/login.html | string | `` | no |
| vault_path | Path to apiary secrets in vault | string | `` | no |
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
