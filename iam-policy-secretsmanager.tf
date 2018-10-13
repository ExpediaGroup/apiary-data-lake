/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "secretsmanager_for_ecs_readonly" {
  count = "${ var.external_database_host == "" ? 1 : 0 }"
  name  = "secretsmanager"
  role  = "${aws_iam_role.apiary_task_readonly.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "${data.aws_secretsmanager_secret.db_ro_user.arn}"
    }
}
EOF
}

resource "aws_iam_role_policy" "secretsmanager_for_ecs_task_readwrite" {
  count = "${ var.external_database_host == "" ? 1 : 0 }"
  name  = "secretsmanager"
  role  = "${aws_iam_role.apiary_task_readwrite.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "${data.aws_secretsmanager_secret.db_rw_user.arn}"
    }
}
EOF
}
