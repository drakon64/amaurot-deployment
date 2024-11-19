resource "google_cloud_run_v2_service" "processor" {
  count = var.built ? 1 : 0

  location = var.region
  name     = "amaurot-processor"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${data.google_project.project.name}/amaurot/amaurot-processor:latest"

      env {
        name = "GITHUB_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secret["client-id"].name
            version = "latest"
          }
        }
      }

      env {
        name = "GITHUB_PRIVATE_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secret["private-key"].name
            version = "latest"
          }
        }
      }

      resources {
        cpu_idle = true

        limits = {
          cpu    = "1000m"
          memory = "256Mi"
        }
      }

      startup_probe {
        failure_threshold = 3

        http_get {
          path = "/"
        }

        initial_delay_seconds = 1
        period_seconds        = 3
        timeout_seconds       = 3
      }
    }

    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }

    session_affinity = true
    service_account  = google_service_account.processor.email
  }

  depends_on = [
    google_project_service.cloud_run,
    google_secret_manager_secret_iam_member.processor
  ]
}

resource "google_cloud_run_v2_service_iam_binding" "processor" {
  count = var.built ? 1 : 0

  members = [google_service_account.receiver.member]
  name    = google_cloud_run_v2_service.processor[0].name
  role    = "roles/run.invoker"
}
