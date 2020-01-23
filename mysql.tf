resource "kubernetes_config_map" "mysql_datasource" {
  metadata {
    name      = "mysql-datasource"
    namespace = "monitoring"

    labels = {
      grafana_datasource = "true"
    }
  }

  data = {
    "mysql-datasource.yaml" = <<EOF
  - name: MySQL
    type: mysql
    url: "${var.external_database_host == "" ? join("", aws_rds_cluster.apiary_cluster.*.reader_endpoint) : var.external_database_host}:3306"
    database: "${var.apiary_database_name}"
    user: "${data.external.db_ro_user.result["username"]}"
    password: "${data.external.db_ro_user.result["password"]}"
    jsonData:
      maxOpenConns: 0
      maxIdleConns: 2
      connMaxLifetime: 14400
EOF
  }
}
