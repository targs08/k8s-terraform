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

variable "packages" {
  type = list(string)
  description = "Extra packages for rpm-ostree repository"
  default = []

}