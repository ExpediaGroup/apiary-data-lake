/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "hms_readwrite" {
  template = file("${path.module}/templates/apiary-hms-readwrite.json")

  vars = {
    mysql_db_host              = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host}"
    mysql_db_name              = "${var.apiary_database_name}"
    mysql_secret_arn           = "${data.aws_secretsmanager_secret.db_rw_user.arn}"
    hive_metastore_access_mode = "readwrite"
    hms_heapsize               = "${var.hms_rw_heapsize}"
    hms_minthreads             = local.hms_ro_minthreads
    hms_maxthreads             = local.hms_ro_maxthreads
    hms_docker_image           = "${var.hms_docker_image}"
    hms_docker_version         = "${var.hms_docker_version}"
    region                     = "${var.aws_region}"
    loggroup                   = "${join("", aws_cloudwatch_log_group.apiary_ecs.*.name)}"
    hive_metastore_log_level   = "${var.hms_log_level}"
    nofile_ulimit              = "${var.hms_nofile_ulimit}"
    enable_metrics             = var.enable_hive_metastore_metrics ? "1" : ""
    managed_schemas            = join(",", local.schemas_info[*]["schema_name"])
    instance_name              = "${local.instance_alias}"
    sns_arn                    = var.enable_metadata_events ? join("", aws_sns_topic.apiary_metadata_events.*.arn) : ""
    table_param_filter         = var.enable_metadata_events ? var.table_param_filter : ""
    enable_gluesync            = var.enable_gluesync ? "1" : ""
    gluedb_prefix              = "${local.gluedb_prefix}"

    ranger_service_name           = "${local.instance_alias}-metastore"
    ranger_policy_manager_url     = "${var.ranger_policy_manager_url}"
    ranger_audit_solr_url         = "${var.ranger_audit_solr_url}"
    atlas_kafka_bootstrap_servers = "${var.atlas_kafka_bootstrap_servers}"
    atlas_cluster_name            = "${local.final_atlas_cluster_name}"
    ranger_audit_db_url           = "${var.ranger_audit_db_url}"
    ranger_audit_secret_arn       = "${var.ranger_audit_db_url == "" ? "" : join("", data.aws_secretsmanager_secret.ranger_audit.*.arn)}"
    ldap_url                      = "${var.ldap_url}"
    ldap_ca_cert                  = "${var.ldap_ca_cert}"
    ldap_base                     = "${var.ldap_base}"
    ldap_secret_arn               = "${var.ldap_url == "" ? "" : join("", data.aws_secretsmanager_secret.ldap_user.*.arn)}"
    kafka_bootstrap_servers       = var.kafka_bootstrap_servers
    kafka_topic_name              = var.kafka_topic_name
    system_schema_name            = var.system_schema_name

    #to instruct docker to turn off upgrading hive db schema when using external database
    external_database = "${var.external_database_host == "" ? "" : "1"}"

    #to instruct ECS to use repositoryCredentials for private docker registry
    docker_auth = "${var.docker_registry_auth_secret_name == "" ? "" : format("\"repositoryCredentials\" :{\n \"credentialsParameter\":\"%s\"\n},", join("", data.aws_secretsmanager_secret.docker_registry.*.arn))}"

    s3_enable_inventory = var.s3_enable_inventory ? "1" : ""
    # If user sets "apiary_log_bucket", then they are doing their own access logs mgmt, and not using Apiary's log mgmt.
    s3_enable_logs = local.enable_apiary_s3_log_hive ? "1" : ""

    # Template vars for init container
    init_container_enabled = var.external_database_host == "" ? true : false
    mysql_permissions      = "ALL"
    mysql_master_cred_arn  = aws_secretsmanager_secret.apiary_mysql_master_credentials[0].arn
    mysql_user_cred_arn    = data.aws_secretsmanager_secret.db_rw_user.arn
  }
}

data "template_file" "hms_readonly" {
  template = file("${path.module}/templates/apiary-hms-readonly.json")

  vars = {
    mysql_db_host              = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.reader_endpoint) : var.external_database_host}"
    mysql_db_name              = "${var.apiary_database_name}"
    mysql_secret_arn           = "${data.aws_secretsmanager_secret.db_ro_user.arn}"
    hive_metastore_access_mode = "readonly"
    hms_heapsize               = "${var.hms_ro_heapsize}"
    hms_minthreads             = local.hms_rw_minthreads
    hms_maxthreads             = local.hms_rw_maxthreads
    hms_docker_image           = "${var.hms_docker_image}"
    hms_docker_version         = "${var.hms_docker_version}"
    region                     = "${var.aws_region}"
    loggroup                   = "${join("", aws_cloudwatch_log_group.apiary_ecs.*.name)}"
    hive_metastore_log_level   = "${var.hms_log_level}"
    nofile_ulimit              = "${var.hms_nofile_ulimit}"
    enable_metrics             = var.enable_hive_metastore_metrics ? "1" : ""
    shared_schemas             = "${join(",", var.apiary_shared_schemas)}"
    instance_name              = "${local.instance_alias}"

    ranger_service_name       = "${local.instance_alias}-metastore"
    ranger_policy_manager_url = "${var.ranger_policy_manager_url}"
    ranger_audit_solr_url     = "${var.ranger_audit_solr_url}"
    ranger_audit_db_url       = "${var.ranger_audit_db_url}"
    ranger_audit_secret_arn   = "${var.ranger_audit_db_url == "" ? "" : join("", data.aws_secretsmanager_secret.ranger_audit.*.arn)}"
    ldap_url                  = "${var.ldap_url}"
    ldap_ca_cert              = "${var.ldap_ca_cert}"
    ldap_base                 = "${var.ldap_base}"
    ldap_secret_arn           = "${var.ldap_url == "" ? "" : join("", data.aws_secretsmanager_secret.ldap_user.*.arn)}"

    #to instruct ECS to use repositoryCredentials for private docker registry
    docker_auth = "${var.docker_registry_auth_secret_name == "" ? "" : format("\"repositoryCredentials\" :{\n \"credentialsParameter\":\"%s\"\n},", join("\",\"", concat(data.aws_secretsmanager_secret.docker_registry.*.arn)))}"

    # Template vars for init container
    init_container_enabled = var.external_database_host == "" ? true : false
    mysql_permissions      = "SELECT"
    mysql_write_db         = "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : var.external_database_host}"
    mysql_master_cred_arn  = aws_secretsmanager_secret.apiary_mysql_master_credentials[0].arn
    mysql_user_cred_arn    = data.aws_secretsmanager_secret.db_ro_user.arn
  }
}
