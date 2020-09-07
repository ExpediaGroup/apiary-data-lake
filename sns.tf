/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sns_topic" "apiary_ops_sns" {
  name = "${local.instance_alias}-operational-events"
}

resource "aws_sns_topic" "apiary_metadata_events" {
  count = var.enable_metadata_events ? 1 : 0
  name  = "${local.instance_alias}-metadata-events"

  policy = length(var.apiary_customer_accounts) == 0 ? null : <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {
            "AWS": [ "${join("\",\"", formatlist("arn:aws:iam::%s:root", var.apiary_customer_accounts))}" ]
        },
        "Action": [ "SNS:Subscribe", "SNS:Receive" ],
        "Resource": "arn:aws:sns:*:*:${local.instance_alias}-metadata-events"
    }]
}
POLICY
}

resource "aws_sns_topic" "apiary_data_events" {
  for_each = var.enable_data_events ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if lookup(schema, "enable_data_events_sqs", "0") == "0"
  } : {}
  name = "${local.instance_alias}-${each.value["resource_suffix"]}-data-events"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${local.instance_alias}-${each.value["resource_suffix"]}-data-events",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.apiary_data_bucket[each.key].arn}"}
        }
    }]
}
POLICY
}

resource "aws_sqs_queue" "apiary_data_event_queue" {
  count = local.create_sqs_data_event_queue ? 1 : 0
  name  = "${local.instance_alias}-data-event-queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
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

resource "aws_sqs_queue" "apiary_managed_logs_queue" {
  count = local.enable_apiary_s3_log_management ? 1 : 0
  name  = "${local.instance_alias}-s3-logs-queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${local.instance_alias}-s3-logs-queue",
      "Condition":{
          "ArnEquals":{"aws:SourceArn":"arn:aws:s3:::${local.apiary_s3_logs_bucket}"}
      }
    }
  ]
}
POLICY
}
