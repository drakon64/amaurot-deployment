resource "google_project_service" "firestore" {
  service = "firestore.googleapis.com"
}

resource "google_firestore_database" "firestore" {
  location_id = var.region
  name        = "(default)"
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.firestore]
}

resource "google_project_iam_member" "firestore" {
  member  = google_service_account.processor.member
  project = data.google_project.project.id
  role    = "roles/datastore.user"
}
