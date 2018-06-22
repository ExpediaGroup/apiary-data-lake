/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sns_topic" "apiary_ops_sns" {
  name = "${local.instance_alias}-operational-events"
}

resource "aws_sns_topic" "apiary_metadata_updates" {
  name = "${local.instance_alias}-metadata-updates"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {
            "AWS": [ "${join("\",\"", formatlist("arn:aws:iam::%s:root",var.apiary_customer_accounts))}" ]
        },
        "Action": [ "SNS:Subscribe", "SNS:Receive" ],
        "Resource": "arn:aws:sns:*:*:${local.instance_alias}-metadata-updates"
    }]
}
POLICY
}
