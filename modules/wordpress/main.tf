# Path: modules/wordpress/main.tf

resource "kubernetes_service" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "wordpress"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_secret" "rds_secret" {
  metadata {
    # Ensure the secret name follows Kubernetes naming conventions
    name      = lower(replace(var.rds_secret_name, "[^a-z0-9.-]", "-"))
    namespace = var.namespace
  }
  data = {
    db_host     = var.db_instance_endpoint
    db_user     = var.username
    db_password = var.password
    db_name     = var.db_name
  }
}
