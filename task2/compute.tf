resource "google_compute_instance_template" "web_server" {
  name = "task2-web-server-template"
  description = "task2 template"
  instance_description = "web server"
  can_ip_forward = false
  machine_type = var.my_machine_type
  tags = ["ssh","http"]
  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = data.google_compute_image.centos_7.self_link
    auto_delete = true
    boot = true
  }
  
  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.private_subnet.name
  }
  
  lifecycle {
    create_before_destroy = true
  }

  metadata_startup_script = file(var.test2_startup)

}

data "google_compute_image" "centos_7" {
  family  = "centos-7"
  project = "centos-cloud"
}

# forwarding
resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  name = "task2-global-forwarding-rule"
  project = var.project
  target = google_compute_target_http_proxy.target_http_proxy.self_link
  port_range = "80"
}

resource "google_compute_target_http_proxy" "target_http_proxy" {
  name = "task2-proxy"
  project = var.project
  url_map = google_compute_url_map.url_map.self_link
}

# backend group 
resource "google_compute_backend_service" "backend_service" {
  name = "task2-backend-service"
  project = var.project
  port_name = "http"
  protocol = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks = [ google_compute_health_check.healthcheck.self_link ]
    
  backend {
    group = google_compute_instance_group_manager.web_private_group.instance_group
    balancing_mode = "RATE"
    max_rate_per_instance = 100
  }
}

resource "google_compute_instance_group_manager" "web_private_group"{
  name = "task2-vm-group"
  project = var.project
  base_instance_name = "task2-web"
  zone = var.zone
  version {
    instance_template  = google_compute_instance_template.web_server.self_link
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "healthcheck" {
   name = "task2-healthcheck"
   timeout_sec = 1
   check_interval_sec = 3
   
   http_health_check {
     port = 80
   }
}

resource "google_compute_url_map" "url_map" {
  name = "task2-load-balancer"
  project = var.project
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_autoscaler" "autoscaler" {
  name = "task2-autoscaler"
  project = var.project
  zone = var.zone
  target  = google_compute_instance_group_manager.web_private_group.self_link
 
  autoscaling_policy {
    max_replicas = var.max_replicas
    min_replicas = var.min_replicas
    cooldown_period = var.cooldown
    
    cpu_utilization {
      target = 0.8
    }
  }
}

output "load-balancer-ip-address" {
  value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
}





