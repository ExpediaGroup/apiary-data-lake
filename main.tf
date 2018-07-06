/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_ecs_cluster" "apiary" {
  name = "${local.instance_alias}"
}

resource "aws_iam_role" "apiary_task_exec" {
  name = "${local.instance_alias}-ecs-task-exec-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  role       = "${aws_iam_role.apiary_task_exec.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "apiary_task_readonly" {
  name = "${local.instance_alias}-ecs-task-readonly-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "apiary_task_readwrite" {
  name = "${local.instance_alias}-ecs-task-readwrite-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "rds_for_ecs_readonly" {
  name = "rds"
  role = "${aws_iam_role.apiary_task_readonly.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" :
  [
    {
      "Effect" : "Allow",
      "Action" : ["rds-db:connect"],
      "Resource" : ["arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.apiary_cluster.cluster_resource_id}/iamro"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "rds_for_ecs_task_readwrite" {
  name = "rds"
  role = "${aws_iam_role.apiary_task_readwrite.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" :
  [
    {
      "Effect" : "Allow",
      "Action" : ["rds-db:connect"],
      "Resource" : ["arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.apiary_cluster.cluster_resource_id}/iamrw"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "sns_for_ecs_task_readwrite" {
  count = "${ var.enable_metadata_events == "" ? 0 : 1 }"
  name = "sns"
  role = "${aws_iam_role.apiary_task_readwrite.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" :
  [
    {
      "Effect" : "Allow",
      "Action" : ["SNS:Publish"],
      "Resource" : ["${aws_sns_topic.apiary_metadata_events.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "glue_for_ecs_task_readwrite" {
  count = "${ var.enable_gluesync == "" ? 0 : 1 }"
  name  = "glue"
  role  = "${aws_iam_role.apiary_task_readwrite.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" :
  [
    {
      "Effect" : "Allow",
      "Action" : ["glue:*"],
      "Resource" : ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_data_for_ecs_task_readwrite" {
  count = "${length(local.apiary_data_buckets)}"
  name  = "s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readwrite.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:DeleteObject",
                              "s3:DeleteObjectVersion",
                              "s3:Get*",
                              "s3:List*",
                              "s3:PutBucketLogging",
                              "s3:PutBucketNotification",
                              "s3:PutBucketVersioning",
                              "s3:PutObject",
                              "s3:PutObjectAcl",
                              "s3:PutObjectTagging",
                              "s3:PutObjectVersionAcl",
                              "s3:PutObjectVersionTagging"
                            ],
                  "Resource": [
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "external_s3_data_for_ecs_task_readwrite" {
  count = "${length(var.external_data_buckets)}"
  name  = "external-s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readwrite.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:DeleteObject",
                              "s3:DeleteObjectVersion",
                              "s3:Get*",
                              "s3:List*",
                              "s3:PutBucketLogging",
                              "s3:PutBucketNotification",
                              "s3:PutBucketVersioning",
                              "s3:PutObject",
                              "s3:PutObjectAcl",
                              "s3:PutObjectTagging",
                              "s3:PutObjectVersionAcl",
                              "s3:PutObjectVersionTagging"
                            ],
                  "Resource": [
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "s3_data_for_ecs_task_readonly" {
  count = "${length(local.apiary_data_buckets)}"
  name  = "s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readonly.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:Get*",
                              "s3:List*"
                            ],
                  "Resource": [
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "external_s3_data_for_ecs_task_readonly" {
  count = "${length(var.external_data_buckets)}"
  name  = "external-s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readonly.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:Get*",
                              "s3:List*"
                            ],
                  "Resource": [
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_cloudwatch_log_group" "apiary_ecs" {
  name = "${local.instance_alias}-ecs"
  tags = "${var.apiary_tags}"
}

data "template_file" "hms_readwrite" {
  template = "${file("${path.module}/templates/apiary-hms-readwrite.json")}"

  vars {
    db_host            = "${aws_rds_cluster.apiary_cluster.endpoint}"
    db_name            = "${aws_rds_cluster.apiary_cluster.database_name}"
    instance_type      = "readwrite"
    hms_heapsize       = "${var.hms_rw_heapsize}"
    hms_docker_image   = "${var.hms_docker_image}"
    hms_docker_version = "${var.hms_docker_version}"
    region             = "${var.aws_region}"
    loggroup           = "${aws_cloudwatch_log_group.apiary_ecs.name}"
    vault_addr         = "${var.vault_internal_addr}"
    vault_path         = "${local.vault_path}"
    log_level          = "${var.hms_log_level}"
    nofile_ulimit      = "${var.hms_nofile_ulimit}"
    managed_schemas    = "${join(",",var.apiary_managed_schemas)}"
    instance_name      = "${local.instance_alias}"
    sns_arn            = "${ var.enable_metadata_events == "" ? "" : aws_sns_topic.apiary_metadata_events.arn }"
    enable_gluesync    = "${var.enable_gluesync}"
    disable_dbmgmt     = "${var.disable_database_management}"
    gluedb_prefix      = "${local.gluedb_prefix}"
  }
}

data "template_file" "hms_readonly" {
  template = "${file("${path.module}/templates/apiary-hms-readonly.json")}"

  vars {
    db_host            = "${aws_rds_cluster.apiary_cluster.reader_endpoint}"
    db_name            = "${aws_rds_cluster.apiary_cluster.database_name}"
    hms_heapsize       = "${var.hms_ro_heapsize}"
    hms_docker_image   = "${var.hms_docker_image}"
    hms_docker_version = "${var.hms_docker_version}"
    region             = "${var.aws_region}"
    loggroup           = "${aws_cloudwatch_log_group.apiary_ecs.name}"
    vault_addr         = "${var.vault_internal_addr}"
    vault_path         = "${local.vault_path}"
    log_level          = "${var.hms_log_level}"
    nofile_ulimit      = "${var.hms_nofile_ulimit}"
  }
}

#todo: use variables for memory and cpu
resource "aws_ecs_task_definition" "apiary_hms_readwrite" {
  family                   = "${local.instance_alias}-hms-readwrite"
  task_role_arn            = "${aws_iam_role.apiary_task_readwrite.arn}"
  execution_role_arn       = "${aws_iam_role.apiary_task_exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.hms_rw_heapsize}"
  cpu                      = "512"
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = "${data.template_file.hms_readwrite.rendered}"
}

resource "aws_ecs_task_definition" "apiary_hms_readonly" {
  family                   = "${local.instance_alias}-hms-readonly"
  task_role_arn            = "${aws_iam_role.apiary_task_readonly.arn}"
  execution_role_arn       = "${aws_iam_role.apiary_task_exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.hms_ro_heapsize}"
  cpu                      = "512"
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = "${data.template_file.hms_readonly.rendered}"
}

resource "aws_lb" "apiary_hms_readwrite_lb" {
  name               = "${local.instance_alias}-hms-readwrite-lb"
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  internal           = true
  idle_timeout       = "${var.elb_timeout}"
  tags               = "${var.apiary_tags}"
}

resource "aws_lb_target_group" "apiary_hms_readwrite_tg" {
  name        = "${local.instance_alias}-hms-readwrite-tg"
  port        = 9083
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "hms_readwrite_listener" {
  load_balancer_arn = "${aws_lb.apiary_hms_readwrite_lb.arn}"
  port              = "9083"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.apiary_hms_readwrite_tg.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "hms_readwrite_alias" {
  count   = "${local.enable_route53_records}"
  zone_id = "${data.aws_route53_zone.apiary_zone.zone_id}"
  name    = "${local.instance_alias}-hms-readwrite"
  type    = "A"

  alias {
    name                   = "${aws_lb.apiary_hms_readwrite_lb.dns_name}"
    zone_id                = "${aws_lb.apiary_hms_readwrite_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_lb" "apiary_hms_readonly_lb" {
  name               = "${local.instance_alias}-hms-readonly-lb"
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  internal           = true
  idle_timeout       = "${var.elb_timeout}"
  tags               = "${var.apiary_tags}"
}

resource "aws_vpc_endpoint_service" "hms_readonly" {
  network_load_balancer_arns = ["${aws_lb.apiary_hms_readonly_lb.arn}"]
  acceptance_required        = false
  allowed_principals         = ["${formatlist("arn:aws:iam::%s:root",var.apiary_customer_accounts)}"]
}

resource "aws_vpc_endpoint_connection_notification" "hms_readonly" {
  vpc_endpoint_service_id     = "${aws_vpc_endpoint_service.hms_readonly.id}"
  connection_notification_arn = "${aws_sns_topic.apiary_ops_sns.arn}"
  connection_events           = ["Connect", "Accept", "Reject", "Delete"]
}

resource "aws_vpc_endpoint_service" "hms_readwrite" {
  network_load_balancer_arns = ["${aws_lb.apiary_hms_readwrite_lb.arn}"]
  acceptance_required        = false
  allowed_principals         = "${distinct(split(",",join(",",values(var.apiary_producer_iamroles))))}"
}

resource "aws_vpc_endpoint_connection_notification" "hms_readwrite" {
  vpc_endpoint_service_id     = "${aws_vpc_endpoint_service.hms_readwrite.id}"
  connection_notification_arn = "${aws_sns_topic.apiary_ops_sns.arn}"
  connection_events           = ["Connect", "Accept", "Reject", "Delete"]
}

resource "aws_lb_target_group" "apiary_hms_readonly_tg" {
  name        = "${local.instance_alias}-hms-readonly-tg"
  port        = 9083
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = "${aws_lb.apiary_hms_readonly_lb.arn}"
  port              = "9083"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.apiary_hms_readonly_tg.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "hms_readonly_alias" {
  count   = "${local.enable_route53_records}"
  zone_id = "${data.aws_route53_zone.apiary_zone.zone_id}"
  name    = "${local.instance_alias}-hms-readonly"
  type    = "A"

  alias {
    name                   = "${aws_lb.apiary_hms_readonly_lb.dns_name}"
    zone_id                = "${aws_lb.apiary_hms_readonly_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_security_group" "hms_sg" {
  name   = "${local.instance_alias}-hms"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.apiary_tags}"

  ingress {
    from_port   = 9083
    to_port     = 9083
    protocol    = "tcp"
    cidr_blocks = "${var.ingress_cidr}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.apiary_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "apiary_hms_readwrite_service" {
  name            = "${local.instance_alias}-hms-readwrite-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.apiary.id}"
  task_definition = "${aws_ecs_task_definition.apiary_hms_readwrite.arn}"
  desired_count   = "${var.hms_readwrite_instance_count}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.apiary_hms_readwrite_tg.arn}"
    container_name   = "apiary-hms-readwrite"
    container_port   = 9083
  }

  network_configuration {
    security_groups = ["${aws_security_group.hms_sg.id}"]
    subnets         = ["${var.private_subnets}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.hms_readwrite.arn}"
  }
}

resource "aws_ecs_service" "apiary_hms_readonly_service" {
  name            = "${local.instance_alias}-hms-readonly-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.apiary.id}"
  task_definition = "${aws_ecs_task_definition.apiary_hms_readonly.arn}"
  desired_count   = "${var.hms_readonly_instance_count}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.apiary_hms_readonly_tg.arn}"
    container_name   = "apiary-hms-readonly"
    container_port   = 9083
  }

  network_configuration {
    security_groups = ["${aws_security_group.hms_sg.id}"]
    subnets         = ["${var.private_subnets}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.hms_readonly.arn}"
  }
}

resource "aws_service_discovery_private_dns_namespace" "apiary" {
  name = "${local.instance_alias}-${var.aws_region}.lcl"
  vpc  = "${var.vpc_id}"
}

resource "aws_service_discovery_service" "hms_readwrite" {
  name = "hms-readwrite"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.apiary.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "hms_readonly" {
  name = "hms-readonly"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.apiary.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
