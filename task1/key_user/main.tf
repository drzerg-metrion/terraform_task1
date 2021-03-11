provider "google" {
  version     = "3.20.0"
  credentials = file("/home/myuslia/drzerg/google_cloud/services-exp-labs-1-7fc3cfc14cec.json")

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_service_account" "task1_service3" {
  account_id   = "task1-service-account3"
  display_name = "task1-service-account3"
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


#    getting key from file does no work :(
#Error creating instance: googleapi: Error 400: The encryption key for 'projects/services-exp-labs-1/#zones/us-west1-a/disks/terraform-instance' is not formatted correctly. It must be 256-bit key material #encoded in Base 64 (RFC4648)., customerEncryptionKeyFormatIsInvalid

#    disk_encryption_key_raw = file(var.my_key)
    disk_encryption_key_raw = var.my_key2
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  service_account {
    email  = google_service_account.task1_service3.email
    scopes = ["cloud-platform"]
  }
}



