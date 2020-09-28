variable "arch" {
  default = "amd64"
}

variable "versions" {
//  type = "map"
  default = {
    kubernetes: "v1.18.3",
    cni: "v0.8.2",
    crictl: "v1.17.0",
  }
}

variable "provider_name" {
  default = "custom"
}

variable "etcd_advertise_mode" {
  default = "private"

  validation {
    condition     = can(regex("(private|public)", var.etcd_advertise_mode))
    error_message = "Etcd advertise mode must be private or public."
  }
}

variable "packages" {
  type = list(string)
  description = "Extra packages for rpm-ostree repository"
  default = []

}