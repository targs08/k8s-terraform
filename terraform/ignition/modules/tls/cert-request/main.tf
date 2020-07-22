
resource "tls_private_key" "key" {
  count = var.enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "request" {
  count = var.enabled ? 1 : 0
  key_algorithm = tls_private_key.key[count.index].algorithm
  private_key_pem = tls_private_key.key[count.index].private_key_pem

  subject {
    common_name = var.common_name
    organization = var.organization
  }

  dns_names = var.sans.dns_names
  ip_addresses = var.sans.ip_addresses
}

resource "tls_locally_signed_cert" "cert" {
  count = var.enabled ? 1 : 0

  cert_request_pem = tls_cert_request.request[count.index].cert_request_pem

  ca_cert_pem = var.ca.cert_pem
  ca_private_key_pem = var.ca.private_key_pem
  ca_key_algorithm = var.ca.key_algorithm

  allowed_uses = var.allowed_uses

  validity_period_hours = var.period
}
