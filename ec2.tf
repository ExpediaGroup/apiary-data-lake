/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "aws_ami" "amzn" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-ebs"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "apiary_readwrite_userdata" {
  template = "${file("${path.module}/templates/apiary_userdata.sh")}"

  vars {
    mysql_db_host     = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host}"
    mysql_db_name     = "${var.apiary_database_name}"
    mysql_db_username = "${data.external.db_rw_user.result["username"]}"
    mysql_db_password = "${data.external.db_rw_user.result["password"]}"
    metastore_mode    = "readwrite"
    external_database = "${var.external_database_host == "" ? "" : "1"}"
  }
}

data "template_file" "apiary_readonly_userdata" {
  template = "${file("${path.module}/templates/apiary_userdata.sh")}"

  vars {
    mysql_db_host     = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host}"
    mysql_db_name     = "${var.apiary_database_name}"
    mysql_db_username = "${data.external.db_ro_user.result["username"]}"
    mysql_db_password = "${data.external.db_ro_user.result["password"]}"
    metastore_mode    = "readonly"
    external_database = "${var.external_database_host == "" ? "" : "1"}"
  }
}

resource "aws_instance" "hms_readwrite" {
  count         = "${var.hms_instance_type == "ecs" ? 0 : length(var.private_subnets)}"
  ami           = "${var.ami_id == "" ? data.aws_ami.amzn.id : var.ami_id}"
  instance_type = "${var.ec2_instance_type}"
  key_name      = "${var.key_name}"
  ebs_optimized = true

  subnet_id              = "${var.private_subnets[count.index]}"
  iam_instance_profile   = "${aws_iam_instance_profile.apiary_task_readwrite.id}"
  vpc_security_group_ids = ["${aws_security_group.hms_sg.id}"]

  user_data_base64 = "${base64encode(data.template_file.apiary_readwrite_userdata.rendered)}"

  root_block_device {
    volume_type = "${var.root_vol_type}"
    volume_size = "${var.root_vol_size}"
  }

  tags = "${merge(map("Name", "${local.instance_alias}-hms-rw-${count.index + 1}"), "${var.apiary_tags}")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "hms_readonly" {
  count         = "${var.hms_instance_type == "ecs" ? 0 : length(var.private_subnets)}"
  ami           = "${var.ami_id == "" ? data.aws_ami.amzn.id : var.ami_id}"
  instance_type = "${var.ec2_instance_type}"
  key_name      = "${var.key_name}"
  ebs_optimized = true

  subnet_id              = "${var.private_subnets[count.index]}"
  iam_instance_profile   = "${aws_iam_instance_profile.apiary_task_readonly.id}"
  vpc_security_group_ids = ["${aws_security_group.hms_sg.id}"]

  user_data_base64 = "${base64encode(data.template_file.apiary_readonly_userdata.rendered)}"

  root_block_device {
    volume_type = "${var.root_vol_type}"
    volume_size = "${var.root_vol_size}"
  }

  tags = "${merge(map("Name", "${local.instance_alias}-hms-ro-${count.index + 1}"), "${var.apiary_tags}")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "hms_readwrite" {
  count = "${var.hms_instance_type == "ecs" ? 0 : length(var.private_subnets)}"

  alarm_name = "Auto Reboot - ${aws_instance.hms_readwrite.*.id[count.index]}"

  dimensions {
    InstanceId = "${aws_instance.hms_readwrite.*.id[count.index]}"
  }

  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"

  alarm_description = "This will restart ${local.instance_alias}-hms-rw-${count.index + 1} if the status check fails"

  alarm_actions = ["${local.cw_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "hms_readonly" {
  count = "${var.hms_instance_type == "ecs" ? 0 : length(var.private_subnets)}"

  alarm_name = "Auto Reboot - ${aws_instance.hms_readonly.*.id[count.index]}"

  dimensions {
    InstanceId = "${aws_instance.hms_readonly.*.id[count.index]}"
  }

  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"

  alarm_description = "This will restart ${local.instance_alias}-hms-ro-${count.index + 1} if the status check fails"

  alarm_actions = ["${local.cw_arn}"]
}
