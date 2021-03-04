provider "google" {
  version = "3.5.0"
  credentials = file("/home/myuslia/drzerg/google_cloud/services-exp-labs-1-7fc3cfc14cec.json")

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "new-terraform-network"
}

resource "google_kms_key_ring" "task1_keyring" {
  name     = "keyring-example"
  location = "global"
}

resource "google_kms_crypto_key" "task1_key1" {
  name            = "task1-crypto-key1"
  key_ring        = google_kms_key_ring.task1_keyring.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}


resource "google_service_account" "task1_service" {
  account_id   = "task1-service-account"
  display_name = "task1-service-account"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.my_machine_type

  labels = {
    task = "1"
    environment = "test"
  }

  metadata = {
    serial-port-disable = true
    block-project-ssh-keys = true
  }

  boot_disk {
    initialize_params {
      image = var.my_image_type
    }
    kms_key_self_link = google_kms_crypto_key.task1_key1.self_link
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  service_account {
    email  = google_service_account.task1_service.email
    scopes = ["cloud-platform"]
  }
}



