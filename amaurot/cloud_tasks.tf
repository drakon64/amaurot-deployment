resource "google_project_service" "cloud_tasks" {
  service = "cloudtasks.googleapis.com"
}

resource "google_cloud_tasks_queue" "cloud_tasks" {
  location = var.region

  name = "amaurot-tasks-queue"

  depends_on = [google_project_service.cloud_tasks]
}

resource "google_cloud_tasks_queue_iam_member" "cloud_tasks" {
  member = google_service_account.receiver.member
  name   = google_cloud_tasks_queue.cloud_tasks.name
  role   = "roles/cloudtasks.enqueuer"
}
