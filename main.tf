/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role" "apiary_elb" {
  name = "${local.instance_alias}-elb-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apiary_elb" {
  role       = "${aws_iam_role.apiary_elb.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
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

resource "aws_ecs_task_definition" "apiary_hms_readwrite" {
  family                = "${local.instance_alias}-hms-readwrite"
  container_definitions = "${data.template_file.hms_readwrite.rendered}"
}

resource "aws_ecs_task_definition" "apiary_hms_readonly" {
  family                = "${local.instance_alias}-hms-readonly"
  container_definitions = "${data.template_file.hms_readonly.rendered}"
}

resource "aws_lb" "apiary_hms_readwrite_lb" {
  name               = "${local.instance_alias}-hms-readwrite-lb"
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  internal           = true
  idle_timeout       = "${var.elb_timeout}"
  tags               = "${var.apiary_tags}"
}

resource "aws_route53_zone" "apiary_zone" {
  name   = "${local.apiary_domain_name}"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.apiary_tags}"
}

resource "aws_lb_target_group" "apiary_hms_readwrite_tg" {
  name     = "${local.instance_alias}-hms-readwrite-tg"
  port     = 9083
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

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
  zone_id = "${aws_route53_zone.apiary_zone.zone_id}"
  name    = "hms-readwrite"
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

resource "null_resource" "hms_readonly_endpoint_svc" {
  depends_on = ["aws_lb.apiary_hms_readonly_lb"]

  triggers {
    customers_accounts = "${join(",", var.apiary_customer_accounts)}"
  }

  #  provisioner "local-exec" {
  #    command = "./scripts/enable-private-link.sh ${aws_lb.apiary_hms_readonly_lb.arn} ${join(",", var.apiary_customer_accounts)}"
  #  }
}

resource "aws_lb_target_group" "apiary_hms_readonly_tg" {
  name     = "${local.instance_alias}-hms-readonly-tg"
  port     = 9083
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

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
  zone_id = "${aws_route53_zone.apiary_zone.zone_id}"
  name    = "hms-readonly"
  type    = "A"

  alias {
    name                   = "${aws_lb.apiary_hms_readonly_lb.dns_name}"
    zone_id                = "${aws_lb.apiary_hms_readonly_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_ecs_service" "apiary_hms_readwrite_service" {
  name            = "${local.instance_alias}-hms-readwrite-service"
  cluster         = "${aws_ecs_cluster.apiary.id}"
  task_definition = "${aws_ecs_task_definition.apiary_hms_readwrite.arn}"
  desired_count   = "${var.hms_readwrite_instance_count}"
  iam_role        = "${aws_iam_role.apiary_elb.arn}"
  depends_on      = ["aws_iam_role_policy_attachment.apiary_elb"]

  load_balancer {
    target_group_arn = "${aws_lb_target_group.apiary_hms_readwrite_tg.arn}"
    container_name   = "apiary-hms-readwrite"
    container_port   = 9083
  }
}

resource "aws_ecs_service" "apiary_hms_readonly_service" {
  name            = "${local.instance_alias}-hms-readonly-service"
  cluster         = "${aws_ecs_cluster.apiary.id}"
  task_definition = "${aws_ecs_task_definition.apiary_hms_readonly.arn}"
  desired_count   = "${var.hms_readonly_instance_count}"
  iam_role        = "${aws_iam_role.apiary_elb.arn}"
  depends_on      = ["aws_iam_role_policy_attachment.apiary_elb"]

  load_balancer {
    target_group_arn = "${aws_lb_target_group.apiary_hms_readonly_tg.arn}"
    container_name   = "apiary-hms-readonly"
    container_port   = 9083
  }
}
