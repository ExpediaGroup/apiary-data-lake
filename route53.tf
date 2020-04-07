/**
 * Copyright (C) 2018-2020 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_route53_record" "hms_readwrite_alias" {
  count   = local.enable_route53_records ? 1 : 0
  zone_id = "${data.aws_route53_zone.apiary_zone[0].zone_id}"
  name    = "${local.instance_alias}-hms-readwrite"
  type    = "A"

  alias {
    name                   = "${aws_lb.apiary_hms_rw_lb[0].dns_name}"
    zone_id                = "${aws_lb.apiary_hms_rw_lb[0].zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "hms_readonly_alias" {
  count   = local.enable_route53_records ? 1 : 0
  zone_id = "${data.aws_route53_zone.apiary_zone[0].zone_id}"
  name    = "${local.instance_alias}-hms-readonly"
  type    = "A"

  alias {
    name                   = "${aws_lb.apiary_hms_ro_lb[0].dns_name}"
    zone_id                = "${aws_lb.apiary_hms_ro_lb[0].zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_zone" "apiary" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  name  = "${local.instance_alias}-${var.aws_region}.${var.ecs_domain_extension}"

  vpc {
    vpc_id = "${var.vpc_id}"
  }
}

resource "aws_route53_record" "hms_readwrite" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  name  = "hms-readwrite"

  zone_id = "${aws_route53_zone.apiary[0].id}"
  type    = "CNAME"
  ttl     = "300"
  records = kubernetes_service.hms_readwrite[0].load_balancer_ingress.*.hostname
}

resource "aws_route53_record" "hms_readonly" {
  count = "${var.hms_instance_type == "k8s" ? 1 : 0}"
  name  = "hms-readonly"

  zone_id = "${aws_route53_zone.apiary[0].id}"
  type    = "CNAME"
  ttl     = "300"
  records = kubernetes_service.hms_readonly[0].load_balancer_ingress.*.hostname
}
