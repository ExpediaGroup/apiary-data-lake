/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "s3_data_for_ecs_task_readwrite" {
  count = "${length(local.apiary_data_buckets)}"
  name  = "s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readwrite.id}"

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
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "s3_data_for_ecs_task_readonly" {
  count = "${length(local.apiary_data_buckets)}"
  name  = "s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readonly.id}"

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
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(local.apiary_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "external_s3_data_for_ecs_task_readwrite" {
  count = "${length(var.external_data_buckets)}"
  name  = "external-s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readwrite.id}"

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
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy" "external_s3_data_for_ecs_task_readonly" {
  count = "${length(var.external_data_buckets)}"
  name  = "external-s3-data-${count.index}"
  role  = "${aws_iam_role.apiary_task_readonly.id}"

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
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(var.external_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}
