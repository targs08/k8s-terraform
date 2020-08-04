variable "cidr" {
  type = list(string)
  default = []
}

variable "rules" {
  type = list(object({
    proto = string
    port = number
    cidr = string
    description = string
  }))
  default = []
}