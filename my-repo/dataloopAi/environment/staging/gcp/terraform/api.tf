resource "google_project_service" "container_api" {
  project            = local.project_id
  service            = local.container_api
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  project            = local.project_id
  service            = local.compute_api
  disable_on_destroy = false
}