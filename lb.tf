/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_lb" "apiary_hms_readwrite_lb" {
  name               = "${local.instance_alias}-hms-readwrite-lb"
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  internal           = true
  idle_timeout       = "${var.elb_timeout}"
  tags               = "${var.apiary_tags}"
}

resource "aws_lb_target_group" "apiary_hms_readwrite_tg" {
  depends_on  = ["aws_lb.apiary_hms_readwrite_lb"]
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

resource "aws_lb" "apiary_hms_readonly_lb" {
  name               = "${local.instance_alias}-hms-readonly-lb"
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  internal           = true
  idle_timeout       = "${var.elb_timeout}"
  tags               = "${var.apiary_tags}"
}

resource "aws_lb_target_group" "apiary_hms_readonly_tg" {
  depends_on  = ["aws_lb.apiary_hms_readonly_lb"]
  name        = "${local.instance_alias}-hms-readonly-tg"
  port        = 9083
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "hms_readonly_listener" {
  load_balancer_arn = "${aws_lb.apiary_hms_readonly_lb.arn}"
  port              = "9083"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.apiary_hms_readonly_tg.arn}"
    type             = "forward"
  }
}
