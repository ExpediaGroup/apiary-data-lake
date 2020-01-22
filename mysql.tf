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
    url: apiary-cluster.cluster-ro-cuivrgzvv9cy.us-east-1.rds.amazonaws.com:3306
    database: "${var.apiary_database_name}"
    user: "${var.db_ro_secret_name}"
    jsonData:
      maxOpenConns: 0
      maxIdleConns: 2
      connMaxLifetime: 14400
    EOF
  }
}
