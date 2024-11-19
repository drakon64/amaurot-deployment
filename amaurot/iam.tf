resource "google_service_account" "github_actions" {
  account_id = "github-actions"

  display_name = "GitHub Actions"
}

resource "google_project_iam_member" "github_actions" {
  for_each = toset([
    "owner"
  ])

  member  = google_service_account.github_actions.member
  project = data.google_project.project.id
  role    = "roles/${each.value}"
}

resource "google_service_account" "receiver" {
  account_id = "amaurot-receiver"

  display_name = "Amaurot Receiver"
}

resource "google_service_account_iam_member" "receiver" {
  member             = google_service_account.receiver.member
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.receiver.id
}

resource "google_service_account" "processor" {
  account_id = "amaurot-processor"

  display_name = "Amaurot Processor"
}
