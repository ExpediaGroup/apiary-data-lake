output "hms_readonly_load_balancers" {
  value = var.hms_instance_type == "k8s" && var.enable_vpc_endpoint_services ? [kubernetes_service.hms_readonly[0].status.0.load_balancer.0.ingress.0.hostname] : []
}

output "hms_readwrite_load_balancers" {
  value = var.hms_instance_type == "k8s" && var.enable_vpc_endpoint_services ? [kubernetes_service.hms_readwrite[0].status.0.load_balancer.0.ingress.0.hostname] : []
}

output "managed_database_host" {
  value = var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : ""
}

//export non-kms glue databases
output "glue_database_names" {
  value = compact(concat([
    for db in aws_glue_catalog_database.apiary_glue_database : db.name if local.schemas_info_map[db.name]["encryption"] == "AES256"
  ], [aws_glue_catalog_database.apiary_system_glue_database[0].name]))
  depends_on = [aws_s3_bucket.apiary_data_bucket]
}

output "glue_database_location_uris" {
  value = compact(concat([
    for db in aws_glue_catalog_database.apiary_glue_database : db.location_uri if local.schemas_info_map[db.name]["encryption"] == "AES256"
  ], [aws_glue_catalog_database.apiary_system_glue_database[0].location_uri]))
  depends_on = [aws_s3_bucket.apiary_data_bucket]
}
