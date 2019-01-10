/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "hms_readwrite" {
  template = "${file("${path.module}/templates/apiary-hms-readwrite.json")}"

  vars {
    mysql_db_host              = "${var.external_database_host == "" ? join("",aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host }"
    mysql_db_name              = "${var.apiary_database_name}"
    mysql_secret_arn           = "${data.aws_secretsmanager_secret.db_rw_user.arn}"
    hive_metastore_access_mode = "readwrite"
    hms_heapsize               = "${var.hms_rw_heapsize}"
    hms_docker_image           = "${var.hms_docker_image}"
    hms_docker_version         = "${var.hms_docker_version}"
    region                     = "${var.aws_region}"
    loggroup                   = "${aws_cloudwatch_log_group.apiary_ecs.name}"
    hive_metastore_log_level   = "${var.hms_log_level}"
    nofile_ulimit              = "${var.hms_nofile_ulimit}"
    enable_metrics             = "${var.enable_hive_metastore_metrics}"
    managed_schemas            = "${join(",",var.apiary_managed_schemas)}"
    instance_name              = "${local.instance_alias}"
    sns_arn                    = "${ var.enable_metadata_events == "" ? "" : join("",aws_sns_topic.apiary_metadata_events.*.arn) }"
    enable_gluesync            = "${var.enable_gluesync}"
    gluedb_prefix              = "${local.gluedb_prefix}"

    ranger_service_name       = "${local.instance_alias}-metastore"
    ranger_policy_manager_url = "${var.ranger_policy_manager_url}"
    ranger_audit_solr_url     = "${var.ranger_audit_solr_url}"
    ranger_audit_db_url       = "${var.ranger_audit_db_url}"
    ranger_audit_secret_arn   = "${var.ranger_audit_db_url == "" ? "" : join("",data.aws_secretsmanager_secret.ranger_audit.*.arn)}"
    ldap_url                  = "${var.ldap_url}"
    ldap_ca_cert              = "${var.ldap_ca_cert}"
    ldap_base                 = "${var.ldap_base}"
    ldap_secret_arn           = "${var.ldap_url == "" ? "" : join("",data.aws_secretsmanager_secret.ldap_user.*.arn)}"

    #to instruct docker to turn off upgrading hive db schema when using external database
    external_database = "${var.external_database_host == "" ? "" : "1" }"
  }
}

data "template_file" "hms_readonly" {
  template = "${file("${path.module}/templates/apiary-hms-readonly.json")}"

  vars {
    mysql_db_host            = "${var.external_database_host == "" ? join("",aws_rds_cluster.apiary_cluster.*.reader_endpoint) : var.external_database_host }"
    mysql_db_name            = "${var.apiary_database_name}"
    mysql_secret_arn         = "${data.aws_secretsmanager_secret.db_ro_user.arn}"
    hms_heapsize             = "${var.hms_ro_heapsize}"
    hms_docker_image         = "${var.hms_docker_image}"
    hms_docker_version       = "${var.hms_docker_version}"
    region                   = "${var.aws_region}"
    loggroup                 = "${aws_cloudwatch_log_group.apiary_ecs.name}"
    hive_metastore_log_level = "${var.hms_log_level}"
    nofile_ulimit            = "${var.hms_nofile_ulimit}"
    enable_metrics           = "${var.enable_hive_metastore_metrics}"
    shared_schemas           = "${join(",",var.apiary_shared_schemas)}"
    instance_name            = "${local.instance_alias}"
  }
}
