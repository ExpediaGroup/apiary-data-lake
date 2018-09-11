/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

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
