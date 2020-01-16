resource "random_integer" "graph_id" {
  min     = 1000
  max     = 999999
  count = length(local.apiary_data_buckets)
}

data "template_file" "graphs" {
  template = file("${path.module}/templates/graph.tpl")
  count = length(local.apiary_data_buckets)
  vars = {
    bucket_name = local.apiary_data_buckets[count.index]
    title_bucket_name = local.apiary_managed_schema_names_replaced[count.index]
    graph_id = random_integer.graph_id.*.result[count.index]
  }
}

data "template_file" "dashboard" {
  template = file("${path.module}/templates/dashboards.tpl")
  vars = {
    panels = "[${join(",", data.template_file.graphs.*.rendered)}]"
  }
}

resource "kubernetes_config_map" "grafana-dashboard" {
  metadata {
    name = "tf-generated-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard="true"
    }
  }

  data = {
    "dashboard-test.json" = data.template_file.dashboard.rendered
  }
}