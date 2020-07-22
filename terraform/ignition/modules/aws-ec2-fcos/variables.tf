
variable "fcos_channel" {
  default = "stable"
}

variable "name" {
  type = string
}

variable "key_name" {}

variable "user_data" {}

variable "subnet_id" {
  type = string
}

variable "config" {
  type = list(object({
    type = string
    role = string
    volume_size = string
  }))
  description = "List of options to generate instances"
}


//variable "ssh_public_key" {
//  type = list(string)
//  default = [
//    // deployer public key
//    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDwxUUX6sXPOV1lx6S2wzCkeSYtSi4BJWEzG/5MvdO/7NvI6swJ9wYJZqdeCqfFSO6AXa0oQvJlfsnHkqGzE+UZJuZm96eDt6OoFN9UmeewO466dQHtaP5paM38OSRx87lWcynsnrOziCbPfEx7+LqqMMZeEpi5iDC2NrkdYfckouj7+mzag9VPh/qG6M+MBXb/0o5s1zY+voxvHzhTZPg4uQYHHro6rCq9S/vBRWj5d/ZgPH6WmlSrCk0LtDFbB5ImoLxKhBXvjhp5jh8jxLSs+lWmq2z/uu5JL128t5UP2jMLvBDxuunkk84IzSkz+bbsBTEM1JDFrzGcEicur3l0dOvVKo+7+esQ8c+2IPQR7PPZUpjEefdCDUHIvm+YJGY4Sle00Yh800PU5rNExdg7zz3ApKfvQiw+t95hrmY7v91bbuIS9V7mvCuJJJQstKOldEBS46Ni8HOKNo0exAH8x/JVxcHYzlVWKETEOfIRoIb7xDqEdplh/ASbkLz/nh56v8zI0aaPYUpznMfxETp/AQpScJveWY1O95uXS+zumR+MzMdSdzXMRtJzLLUjRfTIw9LCh+fLrhLiEEZVpGHo1S8eCQmc7pXdfq2cmASTdJDmmHZt+4TdiQuo/Xr+DbOCaay4zs8c5LOvPQQEvOGgy9hcRFiuqOF3Fgzwj8wwZw=="
//  ]
//}
//
//variable "ignition_merge" {
//  type = object({
//    source = string
//    verification = string
//  })
//  description = "Append ignition configuration"
//  default     = {
//    // 2.1.0
//    // source = '{"ignition":{"config":{},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'
//    // source = 'data:text/plain;charset=utf-8;base64,eyJpZ25pdGlvbiI6eyJjb25maWciOnt9LCJ0aW1lb3V0cyI6e30sInZlcnNpb24iOiIyLjEuMCJ9LCJuZXR3b3JrZCI6e30sInBhc3N3ZCI6e30sInN0b3JhZ2UiOnt9LCJzeXN0ZW1kIjp7fX0='
//    // 3.1.0
//    // source = '{"ignition":{"config":{"replace":{"verification":{}}},"proxy":{},"security":{"tls":{}},"timeouts":{},"version":"3.1.0"},"passwd":{},"storage":{},"systemd":{}}'
//    // source = "data:text/plain;charset=utf-8;base64,eyJpZ25pdGlvbiI6eyJjb25maWciOnsicmVwbGFjZSI6eyJ2ZXJpZmljYXRpb24iOnt9fX0sInByb3h5Ijp7fSwic2VjdXJpdHkiOnsidGxzIjp7fX0sInRpbWVvdXRzIjp7fSwidmVyc2lvbiI6IjMuMS4wIn0sInBhc3N3ZCI6e30sInN0b3JhZ2UiOnt9LCJzeXN0ZW1kIjp7fX0="
//    source = "data:text/plain;charset=utf-8;base64,eyJpZ25pdGlvbiI6eyJjb25maWciOnsicmVwbGFjZSI6eyJ2ZXJpZmljYXRpb24iOnt9fX0sInByb3h5Ijp7fSwic2VjdXJpdHkiOnsidGxzIjp7fX0sInRpbWVvdXRzIjp7fSwidmVyc2lvbiI6IjMuMS4wIn0sInBhc3N3ZCI6e30sInN0b3JhZ2UiOnt9LCJzeXN0ZW1kIjp7fX0="
//    verification = ""
//  }
//}