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
  name  = "${local.instance_alias}-metadata-events"

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
  for_each = var.enable_data_events == "1" ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if lookup(schema, "enable_data_event_queue", "0") == "0"
  } : {}
  name  = "${local.instance_alias}-${each.value["replaced_name"]}-data-events"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${local.instance_alias}-${each.value["replaced_name"]}-data-events",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.apiary_data_bucket[each.key].arn}"}
        }
    }]
}
POLICY
}

resource "aws_sqs_queue" "apiary_data_event_queue" {
  name = "${local.instance_alias}-data-event-queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS":"*"},
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${local.instance_alias}-data-event-queue",
      "Condition":{
          "ArnLike":{"aws:SourceArn":"arn:aws:s3:::${local.apiary_bucket_prefix}-*"}
      }
    }
  ]
}
POLICY
}

