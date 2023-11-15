output "hms_readonly_load_balancers" {
  value = var.hms_instance_type == "k8s" && var.enable_vpc_endpoint_services ? kubernetes_service.hms_readonly[0].status.0.load_balancer.0.ingress.0.hostname : []
}

output "hms_readwrite_load_balancers" {
  value = var.hms_instance_type == "k8s" && var.enable_vpc_endpoint_services ? kubernetes_service.hms_readwrite[0].status.0.load_balancer.0.ingress.0.hostname : []
}

output "managed_database_host" {
  value = var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.endpoint) : ""
}
