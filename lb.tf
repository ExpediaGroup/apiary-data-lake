/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_lb" "apiary_hms_rw_lb" {
  name               = "${local.instance_alias}-hms-rw-lb"
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  internal           = true
  idle_timeout       = "${var.elb_timeout}"
  tags               = "${var.apiary_tags}"
}

resource "aws_lb_target_group" "apiary_hms_rw_tg" {
  depends_on  = ["aws_lb.apiary_hms_rw_lb"]
  name        = "${local.instance_alias}-hms-rw-tg"
  port        = 9083
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    protocol = "TCP"
  }

  tags = "${var.apiary_tags}"

}

resource "aws_lb_listener" "hms_rw_listener" {
  load_balancer_arn = "${aws_lb.apiary_hms_rw_lb.arn}"
  port              = "9083"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.apiary_hms_rw_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb" "apiary_hms_ro_lb" {
  name               = "${local.instance_alias}-hms-ro-lb"
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  internal           = true
  idle_timeout       = "${var.elb_timeout}"
  tags               = "${var.apiary_tags}"
}

resource "aws_lb_target_group" "apiary_hms_ro_tg" {
  depends_on  = ["aws_lb.apiary_hms_ro_lb"]
  name        = "${local.instance_alias}-hms-ro-tg"
  port        = 9083
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    protocol = "TCP"
  }

  tags = "${var.apiary_tags}"
}

resource "aws_lb_listener" "hms_ro_listener" {
  load_balancer_arn = "${aws_lb.apiary_hms_ro_lb.arn}"
  port              = "9083"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.apiary_hms_ro_tg.arn}"
    type             = "forward"
  }
}
