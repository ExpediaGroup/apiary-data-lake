/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sns_topic" "apiary_ops_sns" {
  name = "${local.instance_alias}-operational-events"
}

resource "aws_sns_topic" "apiary_metadata_events" {
  count = "${ var.enable_metadata_events == "" ? 0 : 1 }"
  name = "${local.instance_alias}-metadata-events"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {
            "AWS": [ "${join("\",\"", formatlist("arn:aws:iam::%s:root",var.apiary_customer_accounts))}" ]
        },
        "Action": [ "SNS:Subscribe", "SNS:Receive" ],
        "Resource": "arn:aws:sns:*:*:${local.instance_alias}-metadata-events"
    }]
}
POLICY
}

resource "aws_sns_topic" "apiary_data_events" {
  count = "${ var.enable_data_events == "" ? 0 : length(var.apiary_managed_schemas) }"
  name  = "${local.instance_alias}-${var.apiary_managed_schemas[count.index]}-data-events"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${local.instance_alias}-${var.apiary_managed_schemas[count.index]}-data-events",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.apiary_data_bucket.*.arn[count.index]}"}
        }
    }]
}
POLICY
}
