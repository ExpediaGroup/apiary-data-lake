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
    apiVersion: 1
    datasources:
  - name: MySQL
    type: mysql
    url: "${aws_rds_cluster.apiary_cluster.*.endpoint}"
    database: "${var.apiary_database_name}"
    user: "${data.external.db_ro_user.username}"
    password: "${data.external.db_ro_user.password}"
    jsonData:
      maxOpenConns: 0
      maxIdleConns: 2
      connMaxLifetime: 14400
    EOF
  }
}
