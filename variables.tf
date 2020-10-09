variable "namespace" {
  default = "traefik"
}

variable "lets_encrypt_email" {
  default = "admin@example.com"
}

variable "debug_level" {
  default = "WARN"
}

variable "traefik_hostname" {
  default = "traefik.example.com"
}

variable "app_hostname" {
  default = "app.example.com"
}
