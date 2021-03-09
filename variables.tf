variable "project" {
  type    = string
  default = "services-exp-labs-1"
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "zone" {
  type    = string
  default = "us-west1-a"
}

variable "my_machine_type" {
  type    = string
  default = "f1-micro"
}

variable "cidr" {
  type    = string
}

variable "cred_file" {
  type    = string
}

variable "test2_startup" {
  type    = string
}

variable "max_replicas" {
  type = string
  default = "3"
}

variable "min_replicas" {
  type = string
  default = "1"
}

variable "cooldown" {
  type = string
  default = "60"
}


