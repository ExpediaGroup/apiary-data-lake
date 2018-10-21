# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Use MySQL script instead of Terraform provider to solve Terraform first run issue.
- Refactor ECS task definition Environment variable names.
- Migrate secrets from Hashicorp Vault to AWS SecretsManager.
- Option to enable managed S3 buckets request and data transfer metrics.

### Added
- Option to send Hive Metastore metrics to CloudWatch - see [#4](https://github.com/ExpediaInc/apiary-metastore-docker/issues/4).
- Option to use external MySQL database (to support legacy installations) - see [#48](https://github.com/ExpediaInc/apiary-metastore/issues/48).
- Option to associate multiple VPCs to Service Discovery namespace - see
[#66](https://github.com/ExpediaInc/apiary-metastore/issues/66)
