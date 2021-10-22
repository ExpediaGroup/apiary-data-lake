/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_security_group" "hms_ro" {
  count  = var.hms_instance_type == "ecs" ? 1 : 0
  name   = "${local.instance_alias}-hms-ro"
  vpc_id = var.vpc_id
  tags   = var.apiary_tags

  ingress {
    from_port   = 9083
    to_port     = 9083
    protocol    = "tcp"
    cidr_blocks = local.ro_ingress_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hms_rw" {
  count  = var.hms_instance_type == "ecs" ? 1 : 0
  name   = "${local.instance_alias}-hms-rw"
  vpc_id = var.vpc_id
  tags   = var.apiary_tags

  ingress {
    from_port   = 9083
    to_port     = 9083
    protocol    = "tcp"
    cidr_blocks = local.rw_ingress_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
