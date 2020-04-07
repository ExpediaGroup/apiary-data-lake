/**
 * Copyright (C) 2018-2020 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role" "apiary_task_exec" {
  count = "${var.hms_instance_type == "ecs" ? 1 : 0}"
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

  tags = "${var.apiary_tags}"
}

resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  count      = "${var.hms_instance_type == "ecs" ? 1 : 0}"
  role       = "${aws_iam_role.apiary_task_exec[0].id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "apiary_hms_readonly" {
  name = "${local.instance_alias}-${var.iam_name_root}-readonly-${var.aws_region}"

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
     },
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "AWS": "${var.kiam_arn == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Admin" : var.kiam_arn}"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF

  tags = "${var.apiary_tags}"

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
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "Service": "ecs-tasks.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     },
     {
       "Sid": "",
       "Effect": "Allow",
       "Principal": {
         "AWS": "${var.kiam_arn == "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Admin" : var.kiam_arn}"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF

  tags = "${var.apiary_tags}"

  lifecycle {
    create_before_destroy = true
  }
}
