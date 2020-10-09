output "hms_readonly_load_balancers" {
  value = var.hms_instance_type == "k8s" ? kubernetes_service.hms_readonly[0].load_balancer_ingress.*.hostname : []
}

output "hms_readwrite_load_balancers" {
  value = var.hms_instance_type == "k8s" ? kubernetes_service.hms_readwrite[0].load_balancer_ingress.*.hostname : []
}
