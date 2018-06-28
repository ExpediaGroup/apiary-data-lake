/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

output "hms_readonly_dns" {
  value = "${aws_lb.apiary_hms_readonly_lb.dns_name}"
}

output "hms_readwrite_dns" {
  value = "${aws_lb.apiary_hms_readwrite_lb.dns_name}"
}

output "mysql_db_dns" {
  value = "${aws_rds_cluster.apiary_cluster.endpoint}"
}

output "apiary_data_buckets" {
  value = "${local.apiary_data_buckets}"
}
