locals {
  graph_id_base = 100
  number_of_buckets = 2
}

data "template_file" "grafana_graphs" {
  template = file("${path.module}/templates/grafana-graph.tpl")
  count = length(local.apiary_data_buckets)
  vars = {
    bucket_name = local.apiary_data_buckets[count.index]
    title_bucket_name = local.apiary_managed_schema_names_replaced[count.index]
    graph_id = range(local.graph_id_base, local.graph_id_base + length(local.apiary_data_buckets) * local.number_of_buckets, local.number_of_buckets)[count.index]
    aws_region = data.aws_region.current.name
  }
}

data "template_file" "grafana_dashboard_data" {
  template = file("${path.module}/templates/grafana-dashboard.tpl")
  vars = {
    panels = "[${join(",", data.template_file.grafana_graphs.*.rendered)}]"
  }
}

resource "kubernetes_config_map" "grafana_dashboard" {
  count = var.hms_instance_type == "k8s" ? 1 : 0
  metadata {
    name = "apiary-data-lake-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard="true"
    }
  }

  data = {
    "apiary-data-lake-dashboard.json" = data.template_file.grafana_dashboard_data.rendered
  }
}