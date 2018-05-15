/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "aws_vpc" "apiary_vpc" {
  id = "${var.vpc_id}"
}

resource "aws_ecs_cluster" "apiary" {
  name = "apiary"
}

resource "aws_iam_role" "apiary_ecs" {
  name = "apiary-ecs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_for_ec2" {
  name = "cloudwatch-for-ec2"
  role = "${aws_iam_role.apiary_ecs.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Allow ECS cluster to access apiary data buckets
resource "aws_iam_role_policy" "s3_data_for_ec2" {
  count = "${length(var.apiary_data_buckets)}"
  name  = "s3-data-for-ec2-${count.index}"
  role  = "${aws_iam_role.apiary_ecs.id}"

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
                                "arn:aws:s3:::${element(var.apiary_data_buckets, count.index)}/*",
                                "arn:aws:s3:::${element(var.apiary_data_buckets, count.index)}"
                              ]
                }
              ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2" {
  role       = "${aws_iam_role.apiary_ecs.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "apiary_ecs" {
  name = "apiary-ecs"
  role = "${aws_iam_role.apiary_ecs.name}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data")}"

  vars {
    cluster_name = "apiary"
  }
}

resource "aws_security_group" "ecs_cluster" {
  name   = "apiary-ecs-cluster"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.apiary_tags}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ingress_cidr}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.apiary_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami*-ecs-optimized"]
  }
}

resource "aws_launch_configuration" "ecs_cluster" {
  instance_type        = "${var.ecs_instance_type}"
  image_id             = "${data.aws_ami.ecs_ami.id}"
  iam_instance_profile = "${aws_iam_instance_profile.apiary_ecs.id}"
  security_groups      = ["${aws_security_group.ecs_cluster.id}"]
  user_data            = "${data.template_file.user_data.rendered}"
  key_name             = "${var.aws_keyname}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_cluster" {
  name                 = "apiary-ecs-cluster"
  vpc_zone_identifier  = [ "${var.private_subnets}" ]
  min_size             = 0
  max_size             = "${var.ecs_asg_max_size}"
  desired_capacity     = "${max(var.hms_readwrite_instance_count,var.hms_readonly_instance_count)+1}"
  launch_configuration = "${aws_launch_configuration.ecs_cluster.name}"
  health_check_type    = "EC2"
  tags                 = "${concat(list(map("key", "Name", "value", "apiary_ecs", "propagate_at_launch", true)),var.apiary_asg_tags)}"

  lifecycle {
    create_before_destroy = true
  }
}
