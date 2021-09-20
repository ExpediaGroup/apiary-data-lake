/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role" "apiary_task_exec" {
  count = var.hms_instance_type == "ecs" ? 1 : 0
  name  = "${local.instance_alias}-ecs-task-exec-${var.aws_region}"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "Service": "ecs-tasks.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF

  tags = var.apiary_tags
}

resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  count      = var.hms_instance_type == "ecs" ? 1 : 0
  role       = aws_iam_role.apiary_task_exec[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "apiary_hms_readonly" {
  name = "${local.instance_alias}-${var.iam_name_root}-readonly-${var.aws_region}"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
%{if var.kiam_arn != ""}
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "AWS": "${var.kiam_arn}"
       },
       "Action": "sts:AssumeRole"
     },
%{endif}
%{if var.oidc_provider != ""}
     {
       "Effect": "Allow",
       "Principal": {
         "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
       },
       "Action": "sts:AssumeRoleWithWebIdentity",
       "Condition": {
         "StringEquals": {
           "${var.oidc_provider}:sub": "system:serviceaccount:${var.metastore_namespace}:${local.hms_alias}-readonly"
         }
       }
     },
%{endif}
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "Service": "ecs-tasks.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF

  tags = var.apiary_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "apiary_hms_readwrite" {
  name = "${local.instance_alias}-${var.iam_name_root}-readwrite-${var.aws_region}"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
%{if var.kiam_arn != ""}
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "AWS": "${var.kiam_arn}"
       },
       "Action": "sts:AssumeRole"
     },
%{endif}
%{if var.oidc_provider != ""}
     {
       "Effect": "Allow",
       "Principal": {
         "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
       },
       "Action": "sts:AssumeRoleWithWebIdentity",
       "Condition": {
         "StringEquals": {
           "${var.oidc_provider}:sub": "system:serviceaccount:${var.metastore_namespace}:${local.hms_alias}-readwrite"
         }
       }
     },
%{endif}
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "Service": "ecs-tasks.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF

  tags = var.apiary_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "apiary_s3_inventory" {
  name = "${local.instance_alias}-s3-inventory-${var.aws_region}"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
%{if var.kiam_arn != ""}
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "AWS": "${var.kiam_arn}"
       },
       "Action": "sts:AssumeRole"
     },
%{endif}
%{if var.oidc_provider != ""}
     {
       "Effect": "Allow",
       "Principal": {
         "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
       },
       "Action": "sts:AssumeRoleWithWebIdentity",
       "Condition": {
         "StringEquals": {
           "${var.oidc_provider}:sub": "system:serviceaccount:${var.metastore_namespace}:${local.instance_alias}-s3-inventory"
         }
       }
     },
%{endif}
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "Service": "ecs-tasks.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF

  tags = var.apiary_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "s3_data_for_s3_inventory" {
  name = "s3"
  role = aws_iam_role.apiary_s3_inventory.id

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
                                "arn:aws:s3:::${local.s3_inventory_bucket}",
                                "arn:aws:s3:::${local.s3_inventory_bucket}/*"
                              ]
                }
              ]
}
EOF
}
