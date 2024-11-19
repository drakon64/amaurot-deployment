terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6"
    }
  }
}

provider "google" {
  project = "drakon64-amaurot-test"
  region  = var.region
}

data "google_project" "project" {}
