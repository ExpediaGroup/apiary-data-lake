/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_ecs_cluster" "apiary" {
  count = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  name  = "${local.instance_alias}"
  tags  = "${var.apiary_tags}"
}

resource "aws_cloudwatch_log_group" "apiary_ecs" {
  count             = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  name              = "${local.instance_alias}-ecs"
  retention_in_days = "${var.apiary_logs_retention_days}"
  tags              = "${var.apiary_tags}"
}

resource "aws_ecs_task_definition" "apiary_hms_readwrite" {
  count                    = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  family                   = "${local.instance_alias}-hms-readwrite"
  task_role_arn            = "${aws_iam_role.apiary_hms_readwrite.arn}"
  execution_role_arn       = "${aws_iam_role.apiary_task_exec[0].arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.hms_rw_heapsize}"
  cpu                      = "${var.hms_rw_cpu}"
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = "${data.template_file.hms_readwrite.rendered}"
  tags                     = "${var.apiary_tags}"
}

resource "aws_ecs_task_definition" "apiary_hms_readonly" {
  count                    = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  family                   = "${local.instance_alias}-hms-readonly"
  task_role_arn            = "${aws_iam_role.apiary_hms_readonly.arn}"
  execution_role_arn       = "${aws_iam_role.apiary_task_exec[0].arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.hms_ro_heapsize}"
  cpu                      = "${var.hms_ro_cpu}"
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = "${data.template_file.hms_readonly.rendered}"
  tags                     = "${var.apiary_tags}"
}

resource "aws_ecs_service" "apiary_hms_readwrite_service" {
  count           = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  depends_on      = [aws_lb_target_group.apiary_hms_rw_tg]
  name            = "${local.instance_alias}-hms-readwrite-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.apiary[0].id}"
  task_definition = "${aws_ecs_task_definition.apiary_hms_readwrite[0].arn}"
  desired_count   = "${var.hms_rw_ecs_task_count}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.apiary_hms_rw_tg[0].arn}"
    container_name   = "apiary-hms-readwrite"
    container_port   = 9083
  }

  network_configuration {
    security_groups = ["${aws_security_group.hms_sg.id}"]
    subnets         = var.private_subnets
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.hms_readwrite[0].arn}"
  }
}

resource "aws_ecs_service" "apiary_hms_readonly_service" {
  count           = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  depends_on      = [aws_lb_target_group.apiary_hms_ro_tg]
  name            = "${local.instance_alias}-hms-readonly-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.apiary[0].id}"
  task_definition = "${aws_ecs_task_definition.apiary_hms_readonly[0].arn}"
  desired_count   = "${var.hms_ro_ecs_task_count}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.apiary_hms_ro_tg[0].arn}"
    container_name   = "apiary-hms-readonly"
    container_port   = 9083
  }

  network_configuration {
    security_groups = ["${aws_security_group.hms_sg.id}"]
    subnets         = var.private_subnets
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.hms_readonly[0].arn}"
  }
}
