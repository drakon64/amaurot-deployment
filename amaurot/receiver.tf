resource "google_cloud_run_v2_service" "receiver" {
  count = var.built ? 1 : 0

  location = var.region
  name     = "amaurot-receiver"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${data.google_project.project.name}/amaurot/amaurot-receiver:latest"

      env {
        name = "GITHUB_WEBHOOK_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secret["webhook-secret"].name
            version = "latest"
          }
        }
      }

      env {
        name  = "PROCESSOR_URL"
        value = google_cloud_run_v2_service.processor[0].uri
      }

      env {
        name  = "QUEUE_ID"
        value = google_cloud_tasks_queue.cloud_tasks.id
      }

      env {
        name  = "SERVICE_ACCOUNT_EMAIL"
        value = google_service_account.receiver.email
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
    service_account  = google_service_account.receiver.email
  }

  depends_on = [
    google_project_service.cloud_run,
    google_secret_manager_secret_iam_member.receiver
  ]
}
