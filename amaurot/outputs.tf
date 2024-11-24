output "receiver_uri" {
  value = "${google_cloud_run_v2_service.receiver[0].uri}/api/github/webhooks"
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_actions.name
}
