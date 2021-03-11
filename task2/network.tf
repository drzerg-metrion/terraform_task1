resource "google_compute_network" "vpc_network" {
  name = "task2-terraform-network"
  auto_create_subnetworks = "false" 
  routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "private_subnet" {
# provider = "google-beta"
 provider = google-beta

 purpose = "PRIVATE"
 name = "task2-subnet"
 ip_cidr_range = var.cidr
 network = google_compute_network.vpc_network.name
 region = var.region
}

resource "google_compute_address" "nat-ip" {
  name = "task2-nat-ip"
  project = var.project
  region  = var.region
}

resource "google_compute_router" "nat-router" {
  name = "task2-nat-router"
  network = google_compute_network.vpc_network.name
}

resource "google_compute_router_nat" "nat-gateway" {
  name = "task2-nat-gateway"
  router = google_compute_router.nat-router.name
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [ google_compute_address.nat-ip.self_link ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" 
  depends_on = [ google_compute_address.nat-ip ]
}

output "nat_ip_address" {
  value = google_compute_address.nat-ip.address
}

# firewall
# http
resource "google_compute_firewall" "allow-http" {
  name = "task2-http"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"]
}

# ssh
resource "google_compute_firewall" "allow-ssh" {
  name = "task2-ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
}


