
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

variable "discovery_dns" {
  type = string
}

variable "nodes" {
  type = list(string)
  default = []
}

variable "sans" {
  type = object({
    dns_names = list(string)
    ip_addresses = list(string)
  })

  default = {
    dns_names = []
    ip_addresses = []
  }
}