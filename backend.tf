terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.10"
    }
  }

    backend "gcs" {
        bucket = "basic-lock-349116-tfstate"
    }

  required_version = ">= 1.0"
}

provider "google" {
    project = "basic-lock-349116"
}