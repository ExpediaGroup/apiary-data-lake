/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "hms_readwrite" {
  template = "${file("${path.module}/templates/apiary-hms-readwrite.json")}"

  vars {
    db_host            = "${var.external_database_host == "" ? join("",aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host }"
    db_name            = "${var.apiary_database_name}"
    instance_type      = "readwrite"
    hms_heapsize       = "${var.hms_rw_heapsize}"
    hms_docker_image   = "${var.hms_docker_image}"
    hms_docker_version = "${var.hms_docker_version}"
    region             = "${var.aws_region}"
    loggroup           = "${aws_cloudwatch_log_group.apiary_ecs.name}"
    vault_addr         = "${var.vault_internal_addr}"
    vault_path         = "${local.vault_path}"
    vault_login_path   = "${var.vault_login_path}"
    log_level          = "${var.hms_log_level}"
    nofile_ulimit      = "${var.hms_nofile_ulimit}"
    enable_metrics     = "${var.enable_hive_metastore_metrics}"
    managed_schemas    = "${join(",",var.apiary_managed_schemas)}"
    instance_name      = "${local.instance_alias}"
    sns_arn            = "${ var.enable_metadata_events == "" ? "" : join("",aws_sns_topic.apiary_metadata_events.*.arn) }"
    enable_gluesync    = "${var.enable_gluesync}"
    disable_dbmgmt     = "${var.disable_database_management}"
    gluedb_prefix      = "${local.gluedb_prefix}"

    ranger_service_name   = "${local.instance_alias}-metastore"
    ranger_policy_mgr_url = "${replace(var.ranger_policy_mgr_url,"/","\\\\/")}"
    ranger_audit_solr_url = "${replace(var.ranger_audit_solr_url,"/","\\\\/")}"
    ranger_audit_db_url   = "${replace(var.ranger_audit_db_url,"/","\\\\/")}"
    ldap_url              = "${replace(var.ldap_url,"/","\\\\/")}"
    ldap_base             = "${var.ldap_base}"

    #to instruct docker to turn off upgrading hive db schema when using external database
    external_database = "${var.external_database_host == "" ? "" : "1" }"
  }
}

data "template_file" "hms_readonly" {
  template = "${file("${path.module}/templates/apiary-hms-readonly.json")}"

  vars {
    db_host            = "${var.external_database_host == "" ? join("",aws_rds_cluster.apiary_cluster.*.reader_endpoint) : var.external_database_host }"
    db_name            = "${var.apiary_database_name}"
    hms_heapsize       = "${var.hms_ro_heapsize}"
    hms_docker_image   = "${var.hms_docker_image}"
    hms_docker_version = "${var.hms_docker_version}"
    region             = "${var.aws_region}"
    loggroup           = "${aws_cloudwatch_log_group.apiary_ecs.name}"
    vault_addr         = "${var.vault_internal_addr}"
    vault_path         = "${local.vault_path}"
    vault_login_path   = "${var.vault_login_path}"
    log_level          = "${var.hms_log_level}"
    nofile_ulimit      = "${var.hms_nofile_ulimit}"
    enable_metrics     = "${var.enable_hive_metastore_metrics}"
    instance_name      = "${local.instance_alias}"
  }
}
