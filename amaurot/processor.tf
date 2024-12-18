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
            secret  = google_secret_manager_secret.secret["github-private-key"].name
            version = "latest"
          }
        }
      }

      resources {
        cpu_idle = true

        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      startup_probe {
        failure_threshold = 9

        http_get {
          path = "/"
        }

        initial_delay_seconds = 1
        period_seconds        = 1
        timeout_seconds       = 1
      }

      dynamic "volume_mounts" {
        for_each = var.use_ssh_private_key ? [true] : []

        content {
          mount_path = "/ssh"
          name       = "ssh-private-key"
        }
      }
    }

    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }

    session_affinity = true
    service_account  = google_service_account.processor.email

    dynamic "volumes" {
      for_each = var.use_ssh_private_key ? [true] : []

      content {
        name = "ssh-private-key"

        secret {
          default_mode = 256 // 0400 converted from octal to decimal
          secret       = "ssh-private-key"

          items {
            path    = "ssh-private-key"
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    google_project_service.cloud_run,
    google_secret_manager_secret_iam_member.processor,
  ]
}

resource "google_cloud_run_v2_service_iam_binding" "processor" {
  count = var.built ? 1 : 0

  members = [google_service_account.receiver.member]
  name    = google_cloud_run_v2_service.processor[0].name
  role    = "roles/run.invoker"
}
