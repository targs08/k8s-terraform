
locals {
  etcd_dns_default = [
    "etcd.kube-system.svc.cluster.local",
    "etcd.kube-system.svc",
    "etcd.kube-system",
    "etcd"
  ]
}

# TODO: Add user-defined ca
module "ca" {
  source = "../tls/self-signed-cert"

  ca = true

  subject = {
    common_name = "etcd-ca"
    organization = "etcd-ca"
  }

  usage = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

module "apiserver-client" {
  source = "../tls/cert-request"
  ca = module.ca

  common_name = "kube-apiserver-etcd-client"
  organization = "system:masters"

  allowed_uses = [
    "key_encipherment",
    "client_auth",
  ]

  period = var.period
}

module "healthcheck-client" {
  source = "../tls/cert-request"
  ca = module.ca

  common_name = "kube-etcd-healthcheck-client"
  organization = "system:masters"

  allowed_uses = [
    "key_encipherment",
    "client_auth",
  ]

  period = var.period
}