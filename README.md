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
    }
  ]
  apiary_customer_accounts = ["aws_account_no_1", "aws_account_no_2"]
  ingress_cidr             = ["10.0.0.0/8"]
  apiary_assume_roles      = [
    {
        name = "client_name"
        principals = [ "arn:aws:iam::account_number:role/cross-account-role" ]
        schema_names = [ "dm","lz","test_1" ]
        max_session_duration = "7200",
        # allows assumed role in us-east-1 to read dm, lz, and test_1 S3 buckets in both us-east-1 and us-west-2, for example.  
        # If false or absent, can only read S3 bucket in same region where assumed role exists
        allow_cross_region_access = true 
    }
  ]
}
```

## Notes
  The Apiary metastore Docker image is not yet published to a public repository, you can build from this [repo](https://github.com/ExpediaGroup/apiary-metastore-docker) and then publish it to your own ECR.

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2018-2019 Expedia, Inc.
