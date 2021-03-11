provider "google" {
  #  version = "3.20.0"

  credentials = file(var.cred_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}


provider "google-beta" {
  credentials = file(var.cred_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}
