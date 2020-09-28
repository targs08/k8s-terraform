variable "cluster_name" {}

variable "cloud_provider" {
  default = "external"
}

variable "control_plane_host" {}

variable "etcd_endpoints" {
  type = list(string)
  description = "List of etcd endpoint. Default local etcd gateway"
  default = [
    "https://127.0.0.1:23790"
  ]
}

variable "network_plugin" {
  type = string
  default = "kubenet"
}

variable "period" {
  type = string
  // Default is 3 years
  default = 26280
}

variable "s3" {
  type = object({
    enabled = bool
    bucket = string
    path = string
    scheme = string
  })

  default = {
    enabled = false
    bucket = ""
    path = ""
    scheme = "s3"
  }

  description = "Upload to s3"
}
