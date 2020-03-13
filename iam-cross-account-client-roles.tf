/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role" "apiary_assume_role" {
  count                = length(var.apiary_assume_roles)
  name                 = "${local.instance_alias}-${var.apiary_assume_roles[count.index].name}-${var.aws_region}"
  max_session_duration = lookup(var.apiary_assume_roles[count.index], "max_session_duration", "3600")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS":  [ "${join("\",\"", var.apiary_assume_roles[count.index].principals)}" ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = "${var.apiary_tags}"
}

resource "aws_iam_role_policy" "apiary_assume_role_s3" {
  count = length(var.apiary_assume_roles)
  name  = "s3_access"
  role  = "${aws_iam_role.apiary_assume_role[count.index].id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
      ],
      "Resource": [
        "${join("\",\"", [for schema in var.apiary_assume_roles[count.index].schema_names : "arn:aws:s3:::${local.apiary_assume_role_bucket_prefix[count.index]}-${replace(schema, "_", "-")}"])}",
        "${join("\",\"", [for schema in var.apiary_assume_roles[count.index].schema_names : "arn:aws:s3:::${local..apiary_assume_role_bucket_prefix[count.index]}-${replace(schema, "_", "-")}/*"])}"
      ]
    }
  ]
}
EOF
}
