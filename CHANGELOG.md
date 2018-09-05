# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Use MySQL script instead of Terraform provider to solve Terraform first run issue.

### Added
- Option to use external MySQL database (to support legacy installations) - see [#48](https://github.com/ExpediaInc/apiary-metastore/issues/48).
