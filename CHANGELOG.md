# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [6.1.2] - TBD
### Added
- Added apiary_logs_retention_days variable that sets the default retention period of the apiary cloudwatch group. The default is 30 days.

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
