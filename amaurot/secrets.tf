resource "google_project_service" "secret_manager" {
  service = "secretmanager.googleapis.com"
}

resource "google_secret_manager_secret" "secret" {
  for_each = toset([
    "client-id",
    "private-key",
    "webhook-secret"
  ])

  secret_id = each.value

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager]
}

resource "google_secret_manager_secret_iam_member" "receiver" {
  member    = google_service_account.receiver.member
  role      = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.secret["webhook-secret"].secret_id
}

resource "google_secret_manager_secret_iam_member" "processor" {
  for_each = toset([
    "client-id",
    "private-key"
  ])

  member    = google_service_account.processor.member
  role      = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.secret[each.value].secret_id
}
