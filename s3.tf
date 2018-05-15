/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

##
### Apiary S3 policy template
##
data "template_file" "bucket_policy" {
  count    = "${length(var.apiary_data_buckets)}"
  template = "${file("${path.module}/templates/apiary_bucket_policy.json")}"

  vars {
    customer_principal = "${join("\",\"", formatlist("arn:aws:iam::%s:root",var.apiary_customer_accounts))}"
    bucket_name        = "${var.apiary_data_buckets[count.index]}"
  }
}

##
### Apiary S3 data buckets
##
resource "aws_s3_bucket" "apiary_data_bucket" {
  count         = "${length(var.apiary_data_buckets)}"
  bucket        = "${element(var.apiary_data_buckets, count.index)}"
  acl           = "private"
  request_payer = "BucketOwner"
  policy        = "${data.template_file.bucket_policy.*.rendered[count.index]}"
  tags          = "${var.apiary_tags}"

  logging {
    target_bucket = "${var.apiary_log_bucket}"
    target_prefix = "${var.apiary_log_prefix}${var.apiary_data_buckets[count.index]}/"
  }
}
