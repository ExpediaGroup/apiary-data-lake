# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [4.1.1] - 2020-01-23

### Changed
- Updated the grafana dashboard design and panels

## [4.1.0] - 2020-01-24

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
