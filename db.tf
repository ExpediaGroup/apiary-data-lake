/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_db_subnet_group" "apiarydbsg" {
  count       = var.external_database_host == "" ? 1 : 0
  name        = "${local.instance_alias}-dbsg"
  subnet_ids  = var.private_subnets
  description = "Apiary DB Subnet Group"

  tags = merge(map("Name", "Apiary DB Subnet Group"), var.apiary_tags)
}

resource "aws_security_group" "db_sg" {
  count  = var.external_database_host == "" ? 1 : 0
  name   = "${local.instance_alias}-db"
  vpc_id = var.vpc_id
  tags   = var.apiary_tags

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = data.aws_vpc.apiary_vpc.cidr_block_associations.*.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
}

resource "random_id" "snapshot_id" {
  count       = var.external_database_host == "" ? 1 : 0
  byte_length = 8
}

resource "random_string" "db_master_password" {
  count   = var.external_database_host == "" ? 1 : 0
  length  = 16
  special = false
}

resource "aws_rds_cluster_parameter_group" "apiary_rds_param_group" {
  name_prefix = "${local.instance_alias}-param-group"
  family      = var.rds_family # Needs to be kept in sync with aws_rds_cluster.apiary_cluster.engine and version
  description = "Apiary-specific Aurora parameters"
  tags        = merge(map("Name", "${local.instance_alias}-param-group"), var.apiary_tags)

  parameter {
    name  = "max_allowed_packet"
    value = var.rds_max_allowed_packet
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "apiary_cluster" {
  count                               = var.external_database_host == "" ? 1 : 0
  cluster_identifier_prefix           = "${local.instance_alias}-cluster"
  database_name                       = var.apiary_database_name
  master_username                     = var.db_master_username
  master_password                     = random_string.db_master_password[0].result
  backup_retention_period             = var.db_backup_retention
  preferred_backup_window             = var.db_backup_window
  preferred_maintenance_window        = var.db_maintenance_window
  db_subnet_group_name                = aws_db_subnet_group.apiarydbsg[0].name
  vpc_security_group_ids              = compact(concat(list(aws_security_group.db_sg[0].id), var.apiary_rds_additional_sg))
  tags                                = var.apiary_tags
  final_snapshot_identifier           = "${local.instance_alias}-cluster-final-${random_id.snapshot_id[0].hex}"
  iam_database_authentication_enabled = true
  apply_immediately                   = var.db_apply_immediately
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.apiary_rds_param_group.name
  storage_encrypted                   = var.encrypt_db
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "apiary_cluster_instance" {
  count                                 = var.external_database_host == "" ? var.db_instance_count : 0
  identifier_prefix                     = "${local.instance_alias}-instance-${count.index}"
  cluster_identifier                    = aws_rds_cluster.apiary_cluster[0].id
  instance_class                        = var.db_instance_class
  db_subnet_group_name                  = aws_db_subnet_group.apiarydbsg[0].name
  publicly_accessible                   = false
  apply_immediately                     = var.db_apply_immediately
  monitoring_interval                   = var.db_enhanced_monitoring_interval
  monitoring_role_arn                   = var.db_enhanced_monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  performance_insights_enabled          = var.db_enable_performance_insights
  performance_insights_retention_period = var.db_enable_performance_insights ? 7 : null
  tags                                  = var.apiary_tags

  lifecycle {
    create_before_destroy = true
  }
}

# In order to avoid resource collision when deleting & immediately recreating SecretsManager secrets in AWS, we set a random suffix on the name of the secret.
# This allows us to avoid the issue of AWS's imposed 7 day recovery window.
resource "random_string" "secret_name_suffix" {
  count   = var.external_database_host == "" ? 1 : 0
  length  = 8
  special = false
}

resource "aws_secretsmanager_secret" "apiary_mysql_master_credentials" {
  count                   = var.external_database_host == "" ? 1 : 0
  name                    = "${local.instance_alias}_db_master_user_${random_string.secret_name_suffix[0].result}"
  tags                    = var.apiary_tags
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "apiary_mysql_master_credentials" {
  count     = var.external_database_host == "" ? 1 : 0
  secret_id = aws_secretsmanager_secret.apiary_mysql_master_credentials[0].id
  secret_string = jsonencode(
    map(
      "username", var.db_master_username,
      "password", random_string.db_master_password[0].result
    )
  )
}
