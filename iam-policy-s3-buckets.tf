/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "s3_data_for_hms_readwrite" {
  count = "${length(var.apiary_managed_schemas) == 0 ? 0 : 1}"
  name  = "s3"
  role  = "${aws_iam_role.apiary_hms_readwrite.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:DeleteObject",
                              "s3:DeleteObjectVersion",
                              "s3:Get*",
                              "s3:List*",
                              "s3:PutBucketLogging",
                              "s3:PutBucketNotification",
                              "s3:PutBucketVersioning",
                              "s3:PutObject",
                              "s3:PutObjectAcl",
                              "s3:PutObjectTagging",
                              "s3:PutObjectVersionAcl",
                              "s3:PutObjectVersionTagging"
                            ],
                  "Resource": [
                                "${join("\",\"", formatlist("arn:aws:s3:::%s", local.apiary_data_buckets))}",
                                "${join("\",\"", formatlist("arn:aws:s3:::%s/*", local.apiary_data_buckets))}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "s3_data_for_hms_readonly" {
  count = "${length(var.apiary_managed_schemas) == 0 ? 0 : 1}"
  name  = "s3"
  role  = "${aws_iam_role.apiary_hms_readonly.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:Get*",
                              "s3:List*"
                            ],
                  "Resource": [
                                "${join("\",\"", formatlist("arn:aws:s3:::%s", local.apiary_data_buckets))}",
                                "${join("\",\"", formatlist("arn:aws:s3:::%s/*", local.apiary_data_buckets))}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "external_s3_data_for_hms_readwrite" {
  count = "${length(var.external_data_buckets) == 0 ? 0 : 1}"
  name  = "external-s3"
  role  = "${aws_iam_role.apiary_hms_readwrite.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:DeleteObject",
                              "s3:DeleteObjectVersion",
                              "s3:Get*",
                              "s3:List*",
                              "s3:PutBucketLogging",
                              "s3:PutBucketNotification",
                              "s3:PutBucketVersioning",
                              "s3:PutObject",
                              "s3:PutObjectAcl",
                              "s3:PutObjectTagging",
                              "s3:PutObjectVersionAcl",
                              "s3:PutObjectVersionTagging"
                            ],
                  "Resource": [
                                "${join("\",\"", formatlist("arn:aws:s3:::%s", var.external_data_buckets))}",
                                "${join("\",\"", formatlist("arn:aws:s3:::%s/*", var.external_data_buckets))}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "external_s3_data_for_hms_readonly" {
  count = "${length(var.external_data_buckets) == 0 ? 0 : 1}"
  name  = "external-s3"
  role  = "${aws_iam_role.apiary_hms_readonly.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                              "s3:Get*",
                              "s3:List*"
                            ],
                  "Resource": [
                                "${join("\",\"", formatlist("arn:aws:s3:::%s", var.external_data_buckets))}",
                                "${join("\",\"", formatlist("arn:aws:s3:::%s/*", var.external_data_buckets))}"
                              ]
                }
              ]
}
EOF
}
