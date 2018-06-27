/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

##
### Apiary S3 policy template
##
data "template_file" "bucket_policy" {
  count    = "${length(local.apiary_data_buckets)}"
  template = "${file("${path.module}/templates/apiary_bucket_policy.json")}"

  vars {
    customer_principal = "${join("\",\"", formatlist("arn:aws:iam::%s:root",var.apiary_customer_accounts))}"
    bucket_name        = "${local.apiary_data_buckets[count.index]}"
    producer_iamroles  = "${replace(lookup(var.apiary_producer_iamroles,element(concat(var.apiary_managed_schemas,list("")),count.index),"arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"),",","\",\"")}"
  }
}

##
### Apiary S3 data buckets
##
resource "aws_s3_bucket" "apiary_data_bucket" {
  count         = "${length(local.apiary_data_buckets)}"
  bucket        = "${element(local.apiary_data_buckets, count.index)}"
  acl           = "private"
  request_payer = "BucketOwner"
  policy        = "${data.template_file.bucket_policy.*.rendered[count.index]}"
  tags          = "${var.apiary_tags}"

  logging {
    target_bucket = "${var.apiary_log_bucket}"
    target_prefix = "${var.apiary_log_prefix}${local.apiary_data_buckets[count.index]}/"
  }
}

resource "aws_s3_bucket_notification" "data_events" {
  count  = "${ var.enable_data_events == "" ? 0 : length(local.apiary_data_buckets) }"
  bucket = "${aws_s3_bucket.apiary_data_bucket.*.id[count.index]}"

  topic {
    topic_arn     = "${aws_sns_topic.apiary_data_events.*.arn[count.index]}"
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}
