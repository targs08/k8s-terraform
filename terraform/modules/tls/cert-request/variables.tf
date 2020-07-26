variable "enabled" {
  type = bool
  default = true
}

variable "number" {
  type = number
  default = 1
}

variable "common_name" {
  type = string
  default = "cert"
}

variable "organization" {
  type = string
  default = null
}

variable "ca" {
  type = object({
    cert_pem = string
    private_key_pem = string
    key_algorithm = string
  })
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

variable "allowed_uses" {
  type = list(string)
  default = []
}

variable "period" {
  type = string
  // Default is 3 years
  default = 26280
}