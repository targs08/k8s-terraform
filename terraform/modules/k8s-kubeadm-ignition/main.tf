locals {
  k8s_dns_default = [
    "kubernetes.default.svc.cluster.local",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc",
    "kubernetes.default",
    "kubernetes"
  ]
}

module "ca" {
  source = "../tls/self-signed-cert"

  ca = true

  subject = {
    common_name = "kubernetes"
    organization = "kubernetes"
  }

  usage = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

module "front-proxy" {
  source = "../tls/self-signed-cert"

  ca = true

  subject = {
    common_name = "front-proxy"
    organization = "front-proxy"
  }

  usage = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "tls_private_key" "sa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# https://kubernetes.io/docs/reference/setup-tools/kubeadm/implementation-details/#setup-auto-approval-for-new-bootstrap-tokens
# https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/#authorize-kubelet-to-create-csr
module "kubernetes-admin" {
  source = "../tls/cert-request"
  ca = module.ca

  common_name = "kubernetes-admin"
  organization = "system:masters"

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment",
  ]

  period = var.period
}

module "kubernetes-bootstrapper" {
  source = "../tls/cert-request"
  ca = module.ca

  common_name = "kubernetes"
  organization = "system:bootstrappers"

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment",
  ]

  period = var.period
}