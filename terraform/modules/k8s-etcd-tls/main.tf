
locals {
  etcd_dns_default = [
    "etcd.kube-system.svc.cluster.local",
    "etcd.kube-system.svc",
    "etcd.kube-system",
    "etcd"
  ]

  etcd_bootstrap_vars = {
    DISCOVERY_SRV = var.discovery_dns
    INITIAL_CLUSTER_TOKEN = random_string.token.result
    INITIAL_CLUSTER = "empty"
  }
}

resource "random_string" "token" {
  length = 8
  special = false
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

module "etcd" {
  source = "../tls/cert-request"

  count = length(var.nodes) > 0 ? 0 : 1

  ca = module.ca

  common_name = "etcd"

  sans = {
    dns_names    = distinct(concat(local.etcd_dns_default, var.sans.dns_names, ["localhost", var.discovery_dns]))
    ip_addresses = distinct(concat(["127.0.0.1"], var.sans.ip_addresses))
  }

  allowed_uses = [
    "key_encipherment",
    "server_auth",
    "client_auth"
  ]

  period = var.period
}

module "etcd-node" {
  source = "../tls/cert-request"
  count = length(var.nodes)

  ca = module.ca

  common_name = "etcd"

  sans = {
    dns_names    = distinct(concat(local.etcd_dns_default, var.sans.dns_names,
                        ["localhost", var.discovery_dns, element(var.nodes, count.index)]))
    ip_addresses = distinct(concat(["127.0.0.1"], var.sans.ip_addresses))
  }

  allowed_uses = [
    "key_encipherment",
    "server_auth",
    "client_auth"
  ]

  period = var.period
}