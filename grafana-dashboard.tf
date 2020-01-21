locals {
  graph_id_base = 100
  apiary_data_buckets = 2
}

data "template_file" "graphs" {
  template = file("${path.module}/templates/graph.tpl")
  count = length(local.apiary_data_buckets)
  vars = {
    bucket_name = local.apiary_data_buckets[count.index]
    title_bucket_name = local.apiary_managed_schema_names_replaced[count.index]
    graph_id = range(local.graph_id_base, length(local.apiary_data_buckets) * local.apiary_data_buckets, local.apiary_bucket_prefix)[count.index]
  }
}

data "template_file" "dashboard" {
  template = file("${path.module}/templates/dashboards.tpl")
  vars = {
    panels = "[${join(",", data.template_file.graphs.*.rendered)}]"
  }
}

resource "kubernetes_config_map" "grafana-dashboard" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name = "tf-generated-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard="true"
    }
  }

  data = {
    "dashboard.json" = data.template_file.dashboard.rendered
  }
}