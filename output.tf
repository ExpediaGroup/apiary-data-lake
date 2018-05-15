/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

output "hms_readonly_dns" {
  value = "${aws_route53_record.hms_readonly_alias.fqdn}"
}

output "hms_readwrite_dns" {
  value = "${aws_route53_record.hms_readwrite_alias.fqdn}"
}

output "mysql_db_dns" {
  value = "${aws_route53_record.apiarydb_alias.fqdn}"
}

output "apiary_data_buckets" {
  value = "${var.apiary_data_buckets}"
}

output "apiary_data_bucket_arn" {
  value = "${aws_s3_bucket.apiary_data_bucket.*.arn[0]}"
}

output "apiary_metadata_updates_sns" {
  value = "${aws_sns_topic.apiary_metadata_updates.arn}"
}
