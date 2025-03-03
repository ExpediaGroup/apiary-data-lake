# Overview

 This repo contains a Terraform module to deploy the Apiary data lake component. The module deploys various stateful components in a typical Hadoop-compatible data lake in AWS.

For more information please refer to the main [Apiary](https://github.com/ExpediaGroup/apiary) project page.

## Architecture
![Datalake  architecture](docs/apiary_datalake_3d.jpg)

## Key Features
  * Highly Available(HA) metastore service - packaged as Docker container and running on an ECS Fargate Cluster.
  * PrivateLinks - Network load balancers and VPC endpoints to enable federated access to read-only and read/write metastores.
  * Managed schemas - integrated way of managing Hive schemas, S3 buckets and bucket policies.
  * SNS Listener - A Hive metastore event listener to publish all metadata updates to a SNS topic, see [ApiarySNSListener](https://github.com/ExpediaGroup/apiary-extensions/tree/master/apiary-metastore-listener) for more details.
  * Gluesync  - A metastore event listener to replay Hive metadata events in a Glue catalog.
  * Metastore authorization - A metastore pre-event listener to handle authorization using Ranger.
  * Grafana dashboard - If deployed in EKS, a Grafana dashboard will be created that shows S3 bucket sizes for each Apiary bucket.
  * Lake Formation - Databases will be synced in Lake formation as resources to enhance access control.

## Variables
Please refer to [VARIABLES.md](VARIABLES.md).

## Usage

NB: This module currently requires you to use it from a machine with bash, aws, mysql, and jq CLI tools installed.

Example module invocation:
```
module "apiary" {
  source                   = "git::https://github.com/ExpediaGroup/apiary-data-lake.git"
  aws_region               = "us-west-2"
  instance_name            = "test"
  apiary_tags              = "${var.tags}"
  apiary_extra_tags_s3     = "${var.extra_tags_s3}"
  private_subnets          = ["subnet1", "subnet2", "subnet3"]
  vpc_id                   = "vpc-123456"
  hms_docker_image         = "${aws_account}.dkr.ecr.${aws_region}.amazonaws.com/apiary-metastore"
  hms_docker_version       = "1.0.0"
  hms_ro_cpu               = "2048"
  hms_rw_cpu               = "2048"
  hms_ro_heapsize          = "8192"
  hms_rw_heapsize          = "8192"
  apiary_log_bucket        = "s3-logs-bucket"
  db_instance_class        = "db.t2.medium"
  db_backup_retention      = "7"
  apiary_managed_schemas   = [
    {
        schema_name = "db1",
        s3_lifecycle_policy_transition_period = "30"
    },
    {
        schema_name = "db_2",
        s3_storage_class = "INTELLIGENT_TIERING"
    },
    {
        schema_name = "secure_db",
        encryption   = "aws:kms" //supported values for encryption are AES256,aws:kms
        admin_roles = "role1_arn,role2_arn" //kms key management will be restricted to these roles.
        client_roles = "role3_arn,role4_arn" //s3 bucket read/write and kms key usage will be restricted to these roles.
        customer_accounts = "account_id1,account_id2" //this will override module level apiary_customer_accounts
    },
    {
        schema_name = "db_s3_versioning_enabled",
        s3_versioning_enabled = "Enabled", // Enabled/Disabled/Suspended. Once enabled it can only be suspended
        s3_versioning_expiration_days = 2  // If Enabled, default 7
    },
  ]
  apiary_customer_accounts = ["aws_account_no_1", "aws_account_no_2"]
  # single policy with multiple conditions will use AND operator
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_multi-value-conditions.html
  # ; will create seperate policies for each condition, essentially to enable OR operator
  apiary_customer_condition = <<EOF
    "ForAnyValue:StringEquals": {"s3:ExistingObjectTag/security": [ "public"] };
    "StringLike": {"s3:ExistingObjectTag/type": "image*" }
  EOF
  ingress_cidr             = ["10.0.0.0/8"]
  apiary_assume_roles      = [
    {
        name = "client_name"
        principals = [ "arn:aws:iam::account_number:role/cross-account-role" ]
        schema_names = [ "dm","lz","test_1" ]
        max_role_session_duration_seconds = "7200",
        allow_cross_region_access = true 
    }
  ]
}
```

## Notes
  The Apiary metastore Docker image is not yet published to a public repository, you can build from this [repo](https://github.com/ExpediaGroup/apiary-metastore-docker) and then publish it to your own ECR.

  In k8s deployment mode IAM roles can be attached to metastore pods either using [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) or [KIAM](https://github.com/uswitch/kiam), module will use IRSA when `oidc_provider` variable is configured, will use Kiam whne `kiam_arn` variable is configured.

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2018-2019 Expedia, Inc.
