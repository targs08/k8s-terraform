// root CA

resource "tls_private_key" "key" {
  count = var.enabled ? 1 : 0
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

resource "tls_self_signed_cert" "cert" {
  count = var.enabled ? 1 : 0

  key_algorithm = tls_private_key.key[0].algorithm
  private_key_pem = tls_private_key.key[0].private_key_pem

  subject {
    common_name = var.subject.common_name
    organization = var.subject.organization
  }

  is_ca_certificate = var.ca
  validity_period_hours = var.period

  allowed_uses = var.usage
}
