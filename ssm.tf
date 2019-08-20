/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "apiary_readwrite_playbook" {
  template = "${file("${path.module}/templates/apiary_playbook.yml")}"

  vars = {
    aws_region          = "${var.aws_region}"
    mysql_db_host       = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host}"
    mysql_db_name       = "${var.apiary_database_name}"
    mysql_secret_arn    = "${data.aws_secretsmanager_secret.db_rw_user.arn}"
    metastore_mode      = "readwrite"
    external_database   = "${var.external_database_host == "" ? "" : "1"}"
    managed_schemas     = "'${join("','", local.apiary_managed_schema_names_original)}'"
    apiary_data_buckets = "'${join("','", local.apiary_data_buckets)}'"
    sns_arn             = "${var.enable_metadata_events == "" ? "" : join("", aws_sns_topic.apiary_metadata_events.*.arn)}"
  }
}

data "template_file" "apiary_readonly_playbook" {
  template = "${file("${path.module}/templates/apiary_playbook.yml")}"

  vars = {
    aws_region          = "${var.aws_region}"
    mysql_db_host       = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host}"
    mysql_db_name       = "${var.apiary_database_name}"
    mysql_secret_arn    = "${data.aws_secretsmanager_secret.db_ro_user.arn}"
    metastore_mode      = "readonly"
    external_database   = "${var.external_database_host == "" ? "" : "1"}"
    managed_schemas     = "'${join("','", local.apiary_managed_schema_names_original)}'"
    apiary_data_buckets = "'${join("','", local.apiary_data_buckets)}'"
    sns_arn             = ""
  }
}

#to delay ssm assiociation till ansible is installed
resource "null_resource" "readwrite_delay" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"

  triggers = {
    apiary_instance_ids = "${join(",", aws_instance.hms_readwrite.*.id)}"
  }

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

resource "null_resource" "readonly_delay" {
  count = "${var.hms_instance_type == "ecs" ? 0 : 1}"

  triggers = {
    apiary_instance_ids = "${join(",", aws_instance.hms_readonly.*.id)}"
  }

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

resource "aws_ssm_association" "apiary_readwrite_playbook" {
  count            = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "${local.instance_alias}-readwrite-playbook"

  schedule_expression = "rate(30 minutes)"

  targets {
    key    = "InstanceIds"
    values = aws_instance.hms_readwrite.*.id
  }

  parameters = {
    playbook = "${data.template_file.apiary_readwrite_playbook.rendered}"
  }

  depends_on = ["null_resource.readwrite_delay"]
}

resource "aws_ssm_association" "apiary_readonly_playbook" {
  count            = "${var.hms_instance_type == "ecs" ? 0 : 1}"
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "${local.instance_alias}-readonly-playbook"

  schedule_expression = "rate(30 minutes)"

  targets {
    key    = "InstanceIds"
    values = aws_instance.hms_readonly.*.id
  }

  parameters = {
    playbook = "${data.template_file.apiary_readonly_playbook.rendered}"
  }

  depends_on = ["null_resource.readonly_delay"]
}
