terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    ignition = {
      source  = "hashicorp/ignition"
      version = "2.1.0"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
