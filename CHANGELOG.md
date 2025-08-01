# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [7.11.0] - 2025-07-17
### Changed
- Add automatic Glue stats collection.

## [7.10.22] - 2025-07-17
### Changed
- Updated how we construct the glue outputs

## [7.10.21] - 2025-07-15
### Added
- Added var.apiary_extra_tags_s3 to the apiary system bucket.

## [7.10.20] - 2025-06-24
### Added
- Added lifecycle policy to general read-write iamrole permissions for s3 bucket.

## [7.10.19] - 2025-06-18
### Changed
- Added new variable `s3_inventory_optional_fields` to support different optional fields

## [7.10.18] - 2025-06-10
### Changed
- Add Lakeformation customer account default database permissions.

## [7.10.17] - 2025-05-30
### Changed
- Optional variable to create lakeformation data access role.

## [7.10.16] - 2025-05-29
### Changed
- Add delete marker object expiration when s3 versioning is enabled.

## [7.10.15] - 2025-05-23
### Changed
- Fix outputs when gluedb creation is disabled.

## [7.10.14] - 2025-05-22
### Changed
- Optional variable to disable glue database prefix.

## [7.10.13] - 2025-05-19
### Added
- Backwards compatibility with `var.lf_catalog_glue_sync_arn`.

## [7.10.12] - 2025-05-19
### Added
- Changed from LF permissions `aws_iam_role.apiary_hms_readwrite.arn` to `var.lf_catalog_glue_sync_arn`.

## [7.10.11] - 2025-05-16
### Added
- Added variables to support adding custom log4j configuration for readonly,readwrite and housekeeper hms when deployed in Kubernetes.

## [7.10.10] - 2025-05-14
### Added
- Added variable `s3_logs_customer_accounts` to support allowing read access on s3 logs bucket.
- Added varialbe `s3_inventory_expiration_days` to support s3 inventory bucket lifecycle.

## [7.10.9] - 2025-05-14
### Added
- Added outputs for apiary data buckets arns and apiary system bucket arn

## [7.10.8] - 2025-05-12
### Changed
- Fix catalog producer roles access to system Glue database.

## [7.10.7] - 2025-05-08
### Changed
- Output values to export glue database names and locations.
- Add lakeformation permissions for glue default database.

## [7.10.6] - 2025-05-02
### Added
- Add catalog producer roles with access to ALL Glue databases.

## [7.10.5] - 2025-04-29
### Fixed
- Include describe permission in hive metastore lakeformation policy to fix terraform reconcilation.

## [7.10.4] - 2025-04-28
### Added
- Variable to configure Lakeformation customer accounts.

## [7.10.3] - 2025-03-07
### Added
- Add data location permissions for metastore IAM role.

## [7.10.2] - 2025-03-05
### Added
- Variable to configure catalog client ARNs.
- Add table permissions for metastore IAM role to fix issues with few clients.

## [7.10.1] - 2025-03-04
### Added
- Iceberg metadata files are now always accessible cross-account.

## [7.10.0] - 2025-03-03
### Added
- AWS Lake Formation resources created per database if `create_lf_resource` enabled.
- HMS Glue sync listener Lake Formation permissions to create Glue tables if `disable_glue_db_init` & `create_lf_resource`.
- Added `lf_hybrid_access_enabled` to enable Hybrid access in Lake Formation.
- Upgraded providers
  - hashicorp/aws to `5.17.0` (was `4.0`)

## [7.9.6] - 2025-02-26
### Fixed
- Expiration will be 0 when the S3 lifecycle rule is disabled.

## [7.9.5] - 2025-02-26
### Added
- Add option to provision glue databases using terraform instead of metastore startup.

## [7.9.4] - 2025-02-26
### Fixed
- Added `abort_incomplete_multipart_upload` rule into `aws_s3_bucket_lifecycle_configuration` object.

## [7.9.3] - 2025-02-25
### Fixed
- Merged all S3 lifecycle configurations into `aws_s3_bucket_lifecycle_configuration` object.

## [7.9.2] - 2025-02-24
### Fixed
- Fix gluesync on k8s deployment

## [7.9.1] - 2025-01-14
### Added
- Added Splunk env for segrigatting logs for each environment.

## [7.9.0] - 2025-01-09
### Added
- Enabled Splunk for log forwarding and implemented health checks for ECS HMS.

## [7.8.0] - 2024-12-12
### Added
- Hive databases backed by S3 can now have versioning enabled.

## [7.7.0] - 2024-11-19
### Changed
- Updated the hms namespaces for metrics for both readwrite and readonly.
### Added
- Added following variables:
  - `hms_ecs_metrics_readwrite_namespace`
  - `hms_ecs_metrics_readonly_namespace`
  - `hms_k8s_metrics_readwrite_namespace`
  - `hms_k8s_metrics_readonly_namespace`

## [7.6.1] - 2024-10-30
### Changed
- Changed Openmetric to Prometheus in DockerLabels in ECS.

## [7.6.0] - 2024-10-24
### Fixed
- Added condition for `k8s` service account secret creation.
### Added
- Added new variable `ecs_platform_version` to handle ECS platform version update.
- Added new variable `ecs_requires_compatibilities` to support overwriting compatibilities(when with `EC2`, CPU will not able beyond to `8`, and Memorry can not beyond `60G`).

## [7.5.1] - 2024-10-22
### Added
- Added `apiary_extra_tags_s3` variable to add s3 buckets extra tags.

## [7.5.0] - 2024-10-15
### Added
- Added variables `hms_rw_k8s_pdb_settings` and `hms_ro_k8s_pdb_settings` to specify HMS ro and rw PodDisruptionBudget. Uses policy/v1 version which is evailable since kubernetes 1.25+
- Added variables `hms_rw_k8s_rolling_update_strategy` and `hms_ro_k8s_rolling_update_strategy` to specify Deployment rolling update strategy settings for HMS ro and rw pods.

## [7.4.0] - 2024-09-25
### Added
- Added variables `hms_rw_tolerations` and `hms_ro_tolerations` to specify tolerations for the HMS ro and rw pods
- Added variables `hms_rw_node_affinity` and `hms_ro_node_affinity` to specify node affinities for the HMS ro and rw pods

## [7.3.9] - 2024-09-11
### Fixed
- Correct `MYSQL_DB_HOST` in readonly container.

## [7.3.8] - 2024-09-11
### Fixed
- Enable `apiary_db_para_group` only when `external_database_host` not specified.

## [7.3.7] - 2024-09-10
### Fixed
- Set `db_instance_class` default to `db.t4g.medium`.
- Set `db_backup_retention` default to `7`.

## [7.3.6] - 2024-09-10
### Added
- Added new variable `external_database_host_readonly` to handle externel mysql readonly host.
### Removed
- Removed s3 log bucket `INTELLIGENT_TIERING` transistion to reduce extra cost on access log transfer storage class type as log bucket has expiration configured.

## [7.3.5] - 2024-09-02
### Added
- Use unique SID in IAM Policy.

## [7.3.4] - 2024-08-29
### Added
- Add `s3:ListBucketMultipartUploads`, `s3:ListMultipartUploadParts`, and `s3:AbortMultipartUpload` in `apiary-bucket-policy.json`. 

## [7.3.3] - 2024-08-28
### Added
- Parameter(s3_enable_inventory_tables) to enable/disable s3 inventory tables and cron-job.

## [7.3.2] - 2024-08-27
### Fixed
- Fixed schema deny exception policy.
- Added `apiary_governance_iamroles` into deny exception policy.
- Added new variable `apiary_managed_service_iamroles` to handle tagging service IAM roles in deny exception policy.
- Added new variable `system_schema_producer_iamroles` to support system schema producer IAM roles.

## [7.3.1] - 2024-08-26
### Fixed
- Fixed incorrect `s3-inventory` service account secret binding.

## [7.3.0] - 2024-08-20
### Added
- If apiary_managed_schemas has `deny_global_write_access` enabled, only `producer_roles` will be able to write in the specified schema.

## [7.2.3] - 2024-08-14
### Fixed
- Changed terraform cron job api from `kubernetes_cron_job` to `kubernetes_cron_job_v1` to compatible with eks v1.25 and later.

## [7.2.2] - 2024-07-24
### Fixed
- [Issue 266](https://github.com/ExpediaGroup/apiary-data-lake/issues/266) Apiary bucket policies over-enforce encryption

## [7.2.1] - 2024-07-01
### Added
- Issue where requests can hit 10min connection timeout, TCP keepalive prevents NLB closing idle connections. Similar to the issue explained here: https://paramount.tech/blog/2021/07/26/mitigation-of-connection-reset-in-aws.html

## [7.2.0] - 2024-06-26
### Added
- Added `hms_ro_datanucleus_connection_pooling_type`, `hms_rw_datanucleus_connection_pooling_type`, `hms_ro_datanucleus_connection_pool_config`, `hms_rw_datanucleus_connection_pool_config`, `hms_housekeeper_db_connection_pool_size` variables to allow specifying the pooling driver and its config

## [7.1.9] - 2024-06-20
### Fixed
- Housekeeper deployment should not use common `HADOOP_HEAPSIZE` variable since it is a low memory container.

## [7.1.8] - 2024-06-19
### Added
- `hms_housekeeper_additional_environment_variables` variable to provide ability to add a list of environment variables in `hms-housekeeper` deployment.

## [7.1.7] - 2024-06-04
### Fixed
- Fixed k8s IRSA.
- Changed k8s service account creation to compatible with newer version kubernetes provider.(eks 1.24 and later, create service account no longer create account token automatically)

## [7.1.6] - 2024-05-31
### Added
- Add `apiary_domain_private_zone` to provide option to use private or public zone.

## [7.1.5] - 2024-05-22
### Fixed
- Add `copy_tags_to_snapshot` to aws_rds_cluster.

## [7.1.4] - 2024-05-06
### Fixed
- Change provider version for `kubernetes`.

## [7.1.3] - 2024-04-03
### Fixed
- Add tags to ecs services

## [7.1.2] - 2024-04-03
### Fixed
- Added provider source for `datadog`.

## [7.1.1] - 2024-04-03
### Fixed
- Renamed variable from `common_producer_iamroles` to `apiary_common_producer_iamroles` to make the name consistent.
- Change default value for `datadog_key_secret_name` from `null` to `""`.

## [7.1.0] - 2024-03-21
### Added
- Added `common_producer_iamroles` to allow roles read-write access to all Apiary managed schemas.

## [7.0.1] - 2024-01-22
### Added
- Added `datadog-agent` for HMS-Readonly and HMS-Readwrite in ECS.

## [7.0.0] - 2023-11-16
### Changed
- Changed `k8s` API to work with provider 2.x
- Changed Terraform `map` to `tomap` to make it work with newer TF provider(The map function was deprecated in Terraform v0.12 and is no longer available).
- Upgrade AWS provider to `4.x`.
- Removed bucket `ACL` as when bucket `object_ownership` set to `BucketOwnerEnforced`, it's disabled `ACL`.
  
## [6.19.1] - 2023-08-25
### Fixed
- `customer_condition` to ignore trailing semicolon.

## [6.19.0] - 2023-08-16
### Added
- Added variable `enable_hms_housekeeper ` to support hive metastore lock house keeper.

## [6.18.4] - 2023-06-28
### Added
- Added variable `hms_ro_request_partition_limit` & `hms_rw_request_partition_limit` to set hive metastore limit of partition requests.

## [6.18.3] - 2023-06-16
### Changed
- Updated the annotations to include instance_name for `Hive Metastore R/W and R/O` to Datadog UI.

## [6.18.2] - 2023-06-01
### Fixed
- `conditional_consumer_iamroles` were not able to list objects within a buckets.

## [6.18.1] - 2023-05-30
### Changed
- Added `conditional_consumer_iamroles` in principles even when customer_condition is empty.

## [6.18.0] - 2023-05-25
### Added
- Added the annotations to push Prometheus metrics for Hive Metastore R/W and R/O to Datadog UI.

## [6.17.0] - 2023-05-10
### Added
- New block in every S3 bucket policy called `conditional_consumer_iamroles`. It allows S3 read access to certain IAM Roles based on an `apiary_customer_condition`.

## [6.16.0] - 2023-02-10
### Changed
- Update RDS default version from `aurora5.6` to `aurora-mysql5.7`

## [6.15.0] - 2022-11-15
### Added
- Add variable to set custom environment variables for the Hive Metastore

## [6.14.2] - 2022-07-19
### Changed
- Add support for wildcards in consumer iam roles.

## [6.14.1] - 2022-07-19
### Fixed
- Fix k8s metastore cpu limits.

## [6.14.0] - 2022-07-18
### Added
- Add support for enabling RDS Performance Insights and Enhanced Monitoring.  Both will apply to both reader and writer RDS instances.

## [6.13.0] - 2022-07-07
### Added
- Option to enable k8s hive metastore read only instance autoscaling.

## [6.12.4] - 2022-06-03
### Fixed
- Fix k8s read-only metastore to use RDS reader instance.

## [6.12.3] - 2022-06-01
### Fixed
- Fixed SM policy & templates for resource apiary_mysql_master_credentials when external_database_host is in use.

## [6.12.2] - 2022-05-20
### Added
- Add ability to configure size of HMS MySQL connection pool, and configure stats computation on table/partition creation.

## [6.12.1] - 2022-03-17
### Fixed
- Fixed type error in `apiary_consumer_prefix_iamroles` variable.

## [6.12.0] - 2022-03-15
### Added
- Added functionality for allowing certain IAM roles to have unrestricted read access by schema/prefix mapping - see `apiary_consumer_prefix_iamroles`.
- Documented `apiary_consumer_iamroles`, `apiary_consumer_prefix_iamroles`, and `apiary_customer_condition` in `VARIABLES.md`.

## [6.11.5] - 2022-03-01
### Changed
- Disable S3 object ACLs.

## [6.11.4] - 2021-12-10
### Added
- make rds_family as variable

## [6.11.3] - 2021-11-22
### Added
- make EKS & ECS dashboard optional

## [6.11.2] - 2021-11-12
### Added
- Added governance role read and tag objects permission to apiary buckets

## [6.11.1] - 2021-11-02
### Added
- s3 other bucket public access restrictions

## [6.11.0] - 2021-10-28
### Added
- `liveness_probe` and `readiness_probe` for HMS readwrite and HMS readonly.

## [6.10.6] - 2021-10-26
### Added
- Add `restrict_public_buckets = true` to s3 bucket public access settings

## [6.10.5] - 2021-10-21
### Changed
- Add variable to configure read-write metastore service ingress.

## [6.10.4] - 2021-09-21
### Changed
- Attach service account to s3_inventory job when using IRSA.
- Rename s3_inventory cronjob to match service account name, required on new internal clusters.

## [6.10.3] - 2021-08-30
### Fixed
- Fixed problem with s3_inventory_repair cronjob when apiary instance_name is not empty.

## [6.10.2] - 2021-08-18
### Changed
- Changed bucket policy for `deny_iamroles` to only deny "dangerous" actions, including `GetObject`.

## [6.10.1] - 2021-07-23
### Added
- Variable to enable RDS encryption.

## [6.10.0] - 2021-07-21
### Added
- Add support for configuring k8s pods IAM using IRSA.

## [6.9.3] - 2021-07-14
### Added
- Add support to split customer policy condition.

## [6.9.2] - 2021-07-08
### Added
- Added disallow_incompatible_col_type_changes variable to disable hive validation when schema changes. This variable will help Apache Iceberg to make schema-evolution.

## [6.9.1] - 2021-07-08
### Added
- Add support for cross account access to system schema.

## [6.9.0] - 2021-06-22
### Added
- Added apiary_consumer_iamroles variable to grant cross account access to IAM roles.
- Added apiary_customer_condition variable to restrict access using S3 object tags.

## [6.8.1] - 2021-06-17
### Added
- Add support for cross account access to s3 inventory.

## [6.8.0] - 2021-05-10
### Added
- Add support for Apiary-specific RDS parameter groups.
- Add variable to specify RDS/MySQL parameter value for `max_allowed_packet` (default 128MB).

## [6.7.9] - 2021-04-28
### Fixed
- If the S3 bucket specifies an expiration TTL in days that is <= the Intelligent-Tiering transition days, don't create
  a lifecycle `transition` policy. This will prevent errors like:
  ```
  Error: Error putting S3 lifecycle: InvalidArgument: 'Days' in the Expiration action for filter '(prefix=)' must be greater than 'Days' in the Transition action
  ```

## [6.7.8] - 2021-04-01
### Changed
- Added `DenyUnsecureCommunication` policy for `s3-other.tf` buckets.

## [6.7.7] - 2021-03-03
### Changed
- Add variables to configure s3-sqs defaults for spark streaming.

## [6.7.6] - 2021-03-02
### Fixed
- Disable k8s loadbalancer and route53 entries along with vpc endpoint services.

## [6.7.5] - 2021-03-01
### Fixed
- S3 HTTPS bucket policy requirements are now properly enforced.

## [6.7.4] - 2021-03-01
### Changed
- Only publish S3 Create events to managed logs SQS queue.
- Variable to disable creating s3 logs hive database.

## [6.7.3] - 2021-03-01
### Changed
- Terraform 0.12+ formatting.
- Add required version(1.x) for kubernetes provider,to fix issues with 2.x provider.

## [6.7.2] - 2021-01-04
### Fixed
- Fix colliding Grafana dashboard names for multiple Apiary instances.

## [6.7.1] - 2020-11-11
### Fixed
- Fix managed bucket policy with empty_customer_accounts.

## [6.7.0] - 2020-11-09
### Added
- Support to override customer accounts per managed schema.

## [6.6.1] - 2020-11-06
### Added
- Add managed_database_host output.

## [6.6.0] - 2020-10-30
### Added
- Configure bucket ownership controls on apiary managed buckets,cross account object writes will be owned by bucket instead of writer.

## [6.5.3] - 2020-10-09
### Added
- Add metastore load balancer outputs.

## [6.5.2] - 2020-09-08
### Changed
- Enable SQS events on managed logs bucket.

## [6.5.1] - 2020-09-02
### Changed
- [Issue 165](https://github.com/ExpediaGroup/apiary-data-lake/issues/173) Configure metastore IAM roles using apiary bucket prefix.
- Fix init container deployment.

## [6.5.0] - 2020-08-31
### Changed
- [Issue 165](https://github.com/ExpediaGroup/apiary-data-lake/issues/165) Use init containers instead of `mysql` commands to initialize mysql users.

### Removed
- `mysql` dependency for this terraform module.

## [6.4.3] - 2020-08-12
### Fixed
- [Issue 169](https://github.com/ExpediaGroup/apiary-data-lake/issues/169) Added S3:GetBucketAcl to cross-account shared buckets

## [6.4.2] - 2020-08-04
### Fixed
- Variable to disable metastore VPC endpoint services.
- Add `abort_incomplete_multipart_upload_days` to all S3 buckets.
- [Issue 167](https://github.com/ExpediaGroup/apiary-data-lake/issues/167) Fix gluesync in ECS deployments.

## [6.4.1] - 2020-06-18
### Fixed
- [Issue 162](https://github.com/ExpediaGroup/apiary-data-lake/issues/162) Add explicit dependency for S3 public access block to resolve race condition.

## [6.4.0] - 2020-06-16
### Added
- Create `apiary_system` database and buckets. This is pre-work for Ranger access logs Hive tables and other system data. Requires `apiary-metastore-docker` version `1.15.0` or above.

## [6.3.0] - 2020-06-08
### Added
- Added support for SSE-KMS encryption in Apiary managed S3 bucket.

## [6.2.1] - 2020-05-27
### Changed
- Optional `customer_principal` and `producer_iamroles` in Apiary managed bucket policies.

## [6.2.0] - 2020-05-11
### Added
- Variable to deny IAM roles access to Apiary managed S3 buckets.

## [6.1.3] - 2020-05-11
### Changed
- Set min/max size of HMS thread pool based on memory.  Max will be set to 1 connection for every 2MB RAM.  Min will be 0.25% of max.  This will prevent large HMS instances from not having enough threads/connections available.


## [6.1.2] - 2020-05-07
### Changed
- Change type of `apiary_managed_schemas` from `list(any)` to `list(map(string))` to support dynamically-generated schema lists. This type is backward-compatible with previous schema lists.  Schema lists were already lists of maps of strings, but this change makes TF 0.12 work in certain circumstances that were causing a fatal TF error.

## [6.1.1] - 2020-05-04
### Changed
- Fix multiple instance deployment on k8s.

## [6.1.0] - 2020-04-21
### Added
- If Apiary's default S3 access log management is enabled (i.e., `var.apiary_log_bucket` is not set by the user), signal the Hive metastore to create the Hive database `s3_logs_hive` on startup. This is pre-work to prepare for S3 access-log Hive tables in a future version of Apiary. Requires `apiary-metastore-docker` version `1.13.0` or above.


## [6.0.0] - 2020-04-08
### Added
- Per-schema option to send S3 data notifications to an SQS queue.  See `enable_data_events_sqs` in the [apiary_managed_schemas](VARIABLES.md#apiary_managed_schemas) section of [VARIABLES.md](VARIABLES.md)
### Changed
- Changed AWS resources created on a per-schema basis to use Terraform `for_each` instead of `count`.  This includes S3 and SNS resources.
  - This was done to fix the issue of removing a schema in a later deployment.  If the schema removed is not at the end of the `apiary_managed_schemas` list, then when using `count`, Terraform will see different indexes in the state file for the other resources, and will want to delete and recreate them. Using `for_each` references them by `schema_name` in the state file and fixes this issue.
- The following variables changed type from `string` to `bool` since the `string` was acting as a boolean pre-TF 0.12:
  - `db_apply_immediately`, `enable_hive_metastore_metrics`, `enable_gluesync`,
  - `enable_metadata_events`, `enable_data_events`, `enable_s3_paid_metrics`
### Removed
- Removed variable `s3_block_public_access` - Blocking of public access to Apiary S3 buckets is now mandatory.
- Removed quoted variable types in `variables.tf` to follow Terraform 0.12 standards and remove warnings.
### Notes
- *THIS IS A BREAKING CHANGE.* When deploying `6.0.0` on an existing Apiary deployment, the following procedure must be followed:
  - See the `migrate.py` script in the `scripts` folder.
  - This script is used to migrate an Apiary Terraform state file from using `count` for resource indexing to using
      `for_each`, which is how apiary-data-lake v6.0.0+ handles indexed resources.  Without this script, doing an `apply`
      will want to destroy all your S3 resources and then recreate them because they are stored in the `.tfstate` file
      differently.  
  - The migration script needs some external packages installed (see `migrate_requirements.txt`) and then should run in either Python 2.7+ or Python 3.6+.
  - This procedure assumes you have a Terraform app called `apiary-terraform-app` that is the application using this module.
  - Upgrade `apiary-terraform-app` to `apiary-data-lake` v5.3.2.  This will necessitate using Terraform 0.12+ and
    resolving any TF 0.12 incompatibilities in your application code.  TF 0.12.21+ is recommended (will be required later).
  - Plan and apply your Terraform app to make sure it is working and up-to-date.
  - Install Python 3 if you don't yet have a Python installation.
  - Install requirements for this script with `pip install -r migrate_requirements.txt`.
  - Run this script pointing to your terraform state file.  Script can read the state file from either file system or S3. Run it first with dryrun, then live.  Example:
    - `python migrate.py --dryrun --statefile s3://<bucket_name>/<path_to_statefile>/terraform.tfstate`
    - `python migrate.py --statefile s3://<bucket_name>/<path_to_statefile>/terraform.tfstate`
    - Note that appropriate AWS credentials will be needed for S3: AWS_PROFILE, AWS_DEFAULT_REGION, etc.
  - Upgrade `apiary-terraform-app` to use `apiary-data-lake` v6.0.0. If you are not yet using TF 0.12.21+, please upgrade to 0.12.21.
  - Make _only_ the following changes to your `.tf` file that references the `apiary-data-lake` module. Don't make any additions or other changes:
    - If your app is setting `s3_block_public_access`, remove reference to that variable.  Public access blocks are now mandatory.
    - If your app is setting any of the following variables that changed type to `bool`, change the passed value to `true` or `false`:
      - `db_apply_immediately`, `enable_hive_metastore_metrics`, `enable_gluesync`,
      - `enable_metadata_events`, `enable_data_events`, `enable_s3_paid_metrics`  
      - If current code is setting those to `"1"` (or anything non-blank), change to `true.`  If setting to `""`, change to `false`.
  - Now run a plan of your `apiary-terraform-app` that is using `apiary-data-lake` v6.0.0.  It should show no changes needed.
  - Now run an apply of the code.
  - Now you can make changes to use any other v6.0.0 features or make any other changes you want.  E.g, setting `enable_data_events_sqs` in schemas.
- This version of `apiary-data-lake` requires at least Terraform `0.12.21`

## [5.3.2] - 2020-03-26
### Added
- Add S3 replication permissions to producer bucket policy.

## [5.3.1] - 2020-03-24
### Added
- Configuration to delete incomplete multi-part S3 uploads.

### Changed
- Add additional tags to Apiary data buckets using json instead of terraform map.

## [5.3.0] - 2020-03-23
### Added
- Added a tags map to the Apiary S3 data buckets to have additional tags as required.

## [5.2.0] - 2020-03-23
### Added
- Property `s3_object_expiration_days` to `apiary_managed_schemas`, which sets number of days after which objects in the Apiary S3 buckets expire
- Documentation in `VARIABLES.md` for the `apiary_managed_schemas` variable.

## [5.1.0] - 2020-03-18
### Added
- If S3 inventory is enabled, Hive tables will be created for each Apiary schema bucket.  They will be updated on a scheduled basis each day, etc.
- Note that the scheduled job is currently only implemented for Kubernetes deployments of Apiary.
- Variable to configure S3 inventory table update schedule - `s3_inventory_update_schedule`.

## [5.0.0] - 2020-03-16
### Added
- Variable to configure `apiary_assume_roles` cross-region S3 access.
- Documentation in `VARIABLES.md` for the `apiary_assume_roles` variable.

### Changed
- `apiary_assume_roles[i].max_session_duration` renamed to `apiary_assume_roles[i].max_role_session_duration_seconds`.

## [4.4.2] - 2020-03-06
### Added
- Variable to configure S3 inventory output format.

## [4.4.1] - 2020-02-27
### Changed
- Include Size, LastModifiedDate, StorageClass, ETag, IntelligentTieringAccessTier optional fields in S3 inventory.

## [4.4.0] - 2020-02-12

### Added
- Manage logs S3 bucket to capture data bucket access logs, logs bucket will be created when apiary_log_bucket variable is not set.

### Changed
- apiary_log_bucket variable is optional now.

## [4.3.0] - 2020-02-10

### Added
- Added Prometheus scrape annotations to Kubernetes deployments.

### Changed
- Disable CloudWatch dashboard when running on Kubernetes.

## [4.2.0] - 2020-02-06

### Added
- Variable to enable Apiary Kafka metastore listener.

## [4.1.0] - 2020-01-23

### Added
- Templates to configure a Grafana dashboard through the `grafana-dashboard` config map

## [4.0.3] - 2019-12-11

### Added
- Variable `atlas_cluster_name` to configure Atlas cluster name for Atlas hive-bridge.

## [4.0.2] - 2019-11-21

### Changed
- Reduce k8s Hive Metastore process heapsize from 90 to 85 percent of container memory limit.

## [4.0.1] - 2019-11-18

### Added
- Variable to enable Atlas hive-bridge.

## [4.0.0] - 2019-11-13

### Added
- Support for running Hive Metastore on Kubernetes.
- Upgrade to Terraform version 0.12.
- Configuration variable for `apiary_extensions_version`.
- Variable to grant cross account AWS IAM roles write access to Apiary managed S3 buckets using assume policy.
- Variable to enable S3 inventory configuration.
- Variable to enable S3 Block Public Access.

### Changed
- `hms_readwrite` VPC endpoint whitelisted principals list now filters out empty elements.
- Tag VPC endpoint services.
- Add ansible handler to restart hive metastore services on changes to hive-site.xml and hive-env.sh.
- add TABLE_PARAM_FILTER environment variable to hive-env.sh on EC2 to fix beekeeper.

### Removed
- Support for running Hive Metastore on EC2 nodes.

## [3.0.1] - 2019-08-08
### Added
- Support for configuring read-only HMS with Ranger audit-only mode.

## [3.0.0] - 2019-07-01
### Added
- Support for running Hive Metastore on EC2 nodes.

### Changed
- Hive Metastore IAM role names changed from using `ecs-task` to `hms` as name root, variable `iam_name_root` can be used to keep old names.
- Replace hardcoded `us-west-2` as region to variable `${var.aws_region}` in `cloudwatch.tf` - see [#112](https://github.com/ExpediaGroup/apiary-data-lake/issues/112).

## [2.0.3] - 2019-06-07

### Added
- Pass `var.aws_region` to `null_resource.mysql_ro_user`

## [2.0.2] - 2019-06-06

### Added
- `region` flag to `mysql_user.sh` script.

## [2.0.1] - 2019-06-05

### Added
- `region` flag to `mysql_user.sh` script.

## [2.0.0] - 2019-05-23

### Added
- Option to configure S3 storage class for cost optimization.
- Change in structure of `apiary_managed_schemas` variable from list to list of maps.

## [1.1.0] - 2019-05-23

### Added
- Support for docker private registry.
- A new variable to specify TABLE_PARAM_FILTER regex for Hive Metastore listener.
- Support for `_` in `apiary_managed_schemas` variable. Fixes [#5] (https://github.com/ExpediaGroup/apiary/issues/5). Requires version greater than `v1.1.0` of https://github.com/ExpediaGroup/apiary-metastore-docker

## [1.0.5] - 2019-03-12

### Added
- Pin module to use `terraform-aws-provider v1.60.0`

## [1.0.4] - 2019-02-22

### Added
- tag resources that were not yet applying tags - see [#98](https://github.com/ExpediaGroup/apiary-data-lake/issues/98).

### Changed
- Updated read-only metastore whitelist environment variable name.

## [1.0.3] - 2019-02-08

### Added
- Add `db_apply_immediately` variable to fix [#94](https://github.com/ExpediaGroup/apiary-data-lake/issues/94).

### Changed
- Fixed ECS widgets in CloudWatch dashboard - see [#89](https://github.com/ExpediaGroup/apiary-data-lake/issues/89).

## [1.0.2] - 2018-12-18

### Changed
- Fixes [#92](https://github.com/ExpediaGroup/apiary-data-lake/issues/92).

## [1.0.1] - 2018-12-14

### Added
- Option to configure shared hive databases

### Changed
- Shortened the name of NLB and Target Groups to allow more characters in the instance name - see [#65](https://github.com/ExpediaGroup/apiary-data-lake/issues/65).

## [1.0.0] - 2018-10-31

### Changed
- Use MySQL script instead of Terraform provider to solve Terraform first run issue.
- Refactor ECS task definition Environment variable names.
- Migrate secrets from Hashicorp Vault to AWS SecretsManager.
- Option to enable managed S3 buckets request and data transfer metrics.
- Renamed following variables:
  * `ecs_domain_name` to `ecs_domain_extension`
  * `hms_readonly_instance_count` to `hms_ro_ecs_task_count`
  * `hms_readwrite_instance_count` to `hms_rw_ecs_task_count`
- Optimize ECS task S3 policy.

### Added
- Option to send Hive Metastore metrics to CloudWatch - see [#4](https://github.com/ExpediaGroup/apiary-metastore-docker/issues/4).
- Option to use external MySQL database (to support legacy installations) - see [#48](https://github.com/ExpediaGroup/apiary-metastore/issues/48).
- Option to associate multiple VPCs to Service Discovery namespace - see
[#66](https://github.com/ExpediaGroup/apiary-metastore/issues/66)
