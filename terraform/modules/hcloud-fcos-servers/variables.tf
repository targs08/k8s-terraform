variable "name" {
  description = "Cluster name"
}

variable "name_pattern" {
  type = string
  default = "n%d.%s"
  description = "Pattern for generate name of instance"
}

variable "ssh_keys" {
  type = list(string)
  description = "List of ssh keys"
}

variable "config" {
  type = list(object({
    type = string
    location = string
    labels = map(string)
  }))
  description = "List of options to generate Hetzner Cloud instances"
}

variable "ignition" {
  type = string
  description = "Append ignition configuration"
  default = ""
}

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

variable "labels" {
  type    = map(string)
  default = {}
  description = "Labels for all instances"
}
