/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_route53_record" "hms_readwrite_alias" {
  count   = "${local.enable_route53_records}"
  zone_id = "${data.aws_route53_zone.apiary_zone.zone_id}"
  name    = "${local.instance_alias}-hms-readwrite"
  type    = "A"

  alias {
    name                   = "${aws_lb.apiary_hms_rw_lb.dns_name}"
    zone_id                = "${aws_lb.apiary_hms_rw_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "hms_readonly_alias" {
  count   = "${local.enable_route53_records}"
  zone_id = "${data.aws_route53_zone.apiary_zone.zone_id}"
  name    = "${local.instance_alias}-hms-readonly"
  type    = "A"

  alias {
    name                   = "${aws_lb.apiary_hms_ro_lb.dns_name}"
    zone_id                = "${aws_lb.apiary_hms_ro_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_zone" "apiary" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name  = "${local.instance_alias}-${var.aws_region}.${var.ecs_domain_extension}"

  vpc = {
    vpc_id = "${var.vpc_id}"
  }
}

resource "aws_route53_record" "hms_readwrite" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name  = "hms-readwrite"

  zone_id = "${aws_route53_zone.apiary.id}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.hms_readwrite.*.private_ip}"]
}

resource "aws_route53_record" "hms_readonly" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name  = "hms-readonly"

  zone_id = "${aws_route53_zone.apiary.id}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.hms_readonly.*.private_ip}"]
}
