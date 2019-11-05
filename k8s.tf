resource "kubernetes_deployment" "apiary_hms_readwrite" {
  metadata {
    name      = "hms-readwrite"
    namespace = "metastore"

    labels = {
      name = "hms-readwrite"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        name = "hms-readwrite"
      }
    }

    template {
      metadata {
        labels = {
          name = "hms-readwrite"
        }
      }

      spec {
        container {
          image = var.docker_image
          name  = "hms-readwrite"

          env {
            name  = "AWS_REGION"
            value = "${var.aws_region}"
          }

          env {
            name  = "HADOOP_HEAPSIZE"
            value = "${var.aws_region}"
          }


          resources {
            limits {
              memory = "${var.hms_rw_heapsize}Mi"
            }
            requests {
              memory = "${var.hms_rw_heapsize}Mi"
            }
          }
        }
      }
    }
  }
}

/*
resource "kubernetes_deployment" "apiary_hms_readonly" {

}
*/
