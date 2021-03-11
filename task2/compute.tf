#web1
resource "google_compute_instance" "web_server1" {
  name         = "task2-web-server-1"
  zone         = var.zone
  hostname     = "web1.task2"
  machine_type = var.my_machine_type
  tags         = ["ssh", "http"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.private_subnet.name
  }

  metadata_startup_script = file(var.test2_startup)
}

#web2
resource "google_compute_instance" "web_server2" {
  name         = "task2-web-server-2"
  zone         = var.zone
  hostname     = "web2.task2"
  machine_type = var.my_machine_type
  tags         = ["ssh", "http"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.private_subnet.name
  }

  metadata_startup_script = file(var.test2_startup)
}

output "web-1-internal-ip" {
  value = google_compute_instance.web_server1.network_interface.0.network_ip
}
output "web-2-internal-ip" {
  value = google_compute_instance.web_server2.network_interface.0.network_ip
}


# forwarding
resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  name       = "task2-global-forwarding-rule"
  project    = var.project
  target     = google_compute_target_https_proxy.target_https_proxy.self_link
  port_range = "443"
}

resource "google_compute_managed_ssl_certificate" "test2_cert" {
  provider = google-beta
  name     = "test2-cert"
  managed {
    domains = ["task2terraform.info"]
  }
}

resource "google_compute_target_https_proxy" "target_https_proxy" {
  name             = "task2-https-proxy"
  project          = var.project
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.test2_cert.id]
  ssl_policy       = google_compute_ssl_policy.test2-ssl-policy.self_link
}

resource "google_compute_ssl_policy" "test2-ssl-policy" {
  name            = "test2-ssl-policy"
  min_tls_version = "TLS_1_2"
  profile         = "MODERN"
}

resource "google_compute_url_map" "url_map" {
  name            = "task2-url-map"
  project         = var.project
  default_service = google_compute_backend_service.backend_service.self_link

  #  host_rule {
  #    hosts        = ["task2.terraform.test"]
  #    path_matcher = "allpaths"
  #  }

  #  path_matcher {
  #    name            = "allpaths"
  #    default_service = google_compute_backend_service.backend_service.self_link

  #    path_rule {
  #      paths   = ["/*"]
  #      service = google_compute_backend_service.backend_service.self_link
  #    }
  #  }

}


# backend group 
resource "google_compute_backend_service" "backend_service" {
  name          = "task2-backend-service"
  project       = var.project
  port_name     = "http"
  protocol      = "HTTP"
  health_checks = [google_compute_http_health_check.healthcheck.self_link]

  backend {
    group                 = google_compute_instance_group.web_private_group.self_link
    balancing_mode        = "RATE"
    max_rate_per_instance = 100
  }
}

resource "google_compute_http_health_check" "healthcheck" {
  name               = "task2-http-healthcheck"
  request_path       = "/"
  check_interval_sec = 2
  timeout_sec        = 2
}

resource "google_compute_instance_group" "web_private_group" {
  name        = "task2-vm-group"
  description = "Task2 web servers group"
  zone        = var.zone

  instances = [
    google_compute_instance.web_server1.self_link,
    google_compute_instance.web_server2.self_link
  ]

  named_port {
    name = "http"
    port = 80
  }
}


output "load-balancer-ip-address" {
  value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
}





