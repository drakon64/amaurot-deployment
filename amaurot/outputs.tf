output "receiver_uri" {
  value = "${google_cloud_run_v2_service.receiver[0].uri}/api/github/webhooks"
}
