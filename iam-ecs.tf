/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role" "apiary_task_exec" {
  name = "${local.instance_alias}-ecs-task-exec-${var.aws_region}"

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
  role       = "${aws_iam_role.apiary_task_exec.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "apiary_task_readonly" {
  name = "${local.instance_alias}-ecs-task-readonly-${var.aws_region}"

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

resource "aws_iam_role" "apiary_task_readwrite" {
  name = "${local.instance_alias}-ecs-task-readwrite-${var.aws_region}"

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

resource "aws_iam_role_policy" "ecr_permission_for_task_exec" {
  count = var.instance_type == "ecs" ? 1 : 0
  name  = "ecr-permission"
  role  = aws_iam_role.apiary_task_exec.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecr_permission_for_task" {
  count = var.instance_type == "ecs" ? 1 : 0
  name  = "ecr-permission"
  role  = aws_iam_role.apiary_task_readonly.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "ecr_permission_for_task_exec" {
  count = var.instance_type == "ecs" ? 1 : 0
  name  = "ecr-permission"
  role  = aws_iam_role.apiary_task_exec.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecr_permission_for_task" {
  count = var.instance_type == "ecs" ? 1 : 0
  name  = "ecr-permission"
  role  = aws_iam_role.apiary_task_readwrite.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
