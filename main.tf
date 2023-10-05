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