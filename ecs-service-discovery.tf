/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_service_discovery_private_dns_namespace" "apiary" {
  count = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  name  = "${local.instance_alias}-${var.aws_region}.${var.ecs_domain_extension}"
  vpc   = "${var.vpc_id}"
}

resource "aws_service_discovery_service" "hms_readwrite" {
  count = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  name  = "hms-readwrite"

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
  count = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  name  = "hms-readonly"

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

resource "aws_route53_zone_association" "secondary" {
  count      = "${var.hms_instance_type == "ecs" ? length(var.secondary_vpcs) : 0}"
  zone_id    = "${aws_service_discovery_private_dns_namespace.apiary.hosted_zone}"
  vpc_id     = "${element(var.secondary_vpcs, count.index)}"
  vpc_region = "${var.aws_region}"
}
