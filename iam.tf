/**
 * Copyright (C) 2018-2019 Expedia Inc.
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
  role       = "${aws_iam_role.apiary_task_exec.id}"
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
         "Service": [ "ecs-tasks.amazonaws.com", "ec2.amazonaws.com" ]
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
         "Service": [ "ecs-tasks.amazonaws.com", "ec2.amazonaws.com" ]
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

resource "aws_iam_role_policy_attachment" "apiary_readwrite_ssm_policy" {
  count      = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  role       = "${aws_iam_role.apiary_hms_readwrite.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "apiary_readonly_ssm_policy" {
  count      = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  role       = "${aws_iam_role.apiary_hms_readonly.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "apiary_hms_readwrite" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name  = "${aws_iam_role.apiary_hms_readwrite.name}"
  role  = "${aws_iam_role.apiary_hms_readwrite.name}"
}

resource "aws_iam_instance_profile" "apiary_hms_readonly" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name  = "${aws_iam_role.apiary_hms_readonly.name}"
  role  = "${aws_iam_role.apiary_hms_readonly.name}"
}
