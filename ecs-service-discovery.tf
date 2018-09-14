/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

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
