provider "google" {
  version     = "3.20.0"
  credentials = file("/home/myuslia/drzerg/google_cloud/services-exp-labs-1-7fc3cfc14cec.json")

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_kms_key_ring" "task1_keyring2" {
  name     = "keyring-example2"
  location = "global"
}

resource "google_kms_crypto_key" "task1_key2" {
  name     = "task1-crypto-key2"
  key_ring = google_kms_key_ring.task1_keyring2.self_link

  rotation_period = "100000s"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "task1_service2" {
  account_id   = "task1-service-account2"
  display_name = "task1-service-account2"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.my_machine_type

  labels = {
    task        = "1"
    environment = "test"
  }

  metadata = {
    serial-port-enable     = false
    block-project-ssh-keys = true
  }

  boot_disk {
    initialize_params {
      image = var.my_image_type
    }
    kms_key_self_link = google_kms_crypto_key.task1_key2.self_link
  }

  network_interface {
    network = "default"
    access_config {
    }
  }


  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

}



