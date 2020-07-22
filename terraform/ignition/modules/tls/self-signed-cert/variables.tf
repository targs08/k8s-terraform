variable "enabled" {
  type = bool
  default = true
}

variable "ca" {
  type = bool
  default = false
}

variable "algorithm" {
  type = string
  default = "RSA"
}

variable "rsa_bits" {
  type = string
  default = "2048"
}

variable "period" {
  type = string
  // Default is 3 years
  default = 26280
}

# https://www.terraform.io/docs/providers/tls/r/cert_request.html#subject
variable "subject" {
  type = object({
    common_name = string
    organization = string
  })
}

variable "usage" {
  type = list(string)
  default = [
    "digital_signature"
  ]
}

