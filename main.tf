resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "serviceusage" {
  service = "serviceusage.googleapis.com"
  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
  depends_on = [ google_project_service.serviceusage ]
}

resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
  depends_on = [ google_project_service.artifactregistry ]
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  depends_on = [ google_project_service.sqladmin ]
}

resource "google_artifact_registry_repository" "website-tools" {
  location      = "us-central1"
  repository_id = "website-tools"
  description   = "Depo TP Evalue"
  format        = "DOCKER"

  depends_on = [ google_project_service.artifactregistry ]
}

resource "google_sql_database" "wordpress" {
  name     = "wordpress"
  instance = "main-instance"
}
#resource "google_sql_database_instance" "main-instance" {
#  name             = "main-instance"
#  region           = "us-central1"
#  database_version = "MYSQL_8_0"
#  settings {
#    tier = "db-f1-micro"
#  }

 # deletion_protection  = "true"
#}

resource "google_sql_user" "wordpress" {
   name     = "wordpress"
   instance = "main-instance"
   password = "ilovedevops"
}

resource "google_cloud_run_service" "default" {
name     = "serveur-wordpress"
location = "us-central1"

template {
   spec {
      containers {
        image = "us-central1-docker.pkg.dev/basic-lock-349116/website-tools/cb-wordpress-image@sha256:80c456b1de2ac82087fea298a71325ad03fc604821d6be3cdb461a594e315741"
        ports {
          container_port = 80
        }
      }
   }

   metadata {
      annotations = {
            "run.googleapis.com/cloudsql-instances" = "basic-lock-349116:us-central1:main-instance"
      }
   }
}

traffic {
   percent         = 100
   latest_revision = true
}
}

data "google_iam_policy" "noauth" {
   binding {
      role = "roles/run.invoker"
      members = [
         "allUsers",
      ]
   }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = google_cloud_run_service.default.location
   project     = google_cloud_run_service.default.project
   service     = google_cloud_run_service.default.name

   policy_data = data.google_iam_policy.noauth.policy_data
}