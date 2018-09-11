/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "cloudwatch_for_ecs_readonly" {
  name = "cloudwatch"
  role = "${aws_iam_role.apiary_task_readonly.id}"

  policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": [
                 "cloudwatch:PutMetricData",
                 "cloudwatch:GetMetricStatistics",
                 "cloudwatch:ListMetrics",
                 "ec2:DescribeTags"
             ],
             "Resource": "*"
         }
     ]
 }
EOF
}

resource "aws_iam_role_policy" "cloudwatch_for_ecs_readwrite" {
  name = "cloudwatch"
  role = "${aws_iam_role.apiary_task_readwrite.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
