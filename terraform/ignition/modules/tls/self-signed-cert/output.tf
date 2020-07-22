output "cert_pem" {
  value = element(tls_self_signed_cert.cert.*.cert_pem, 0)
}

output "key_algorithm" {
  value = element(tls_self_signed_cert.cert.*.key_algorithm, 0)
}

output "private_key_pem" {
  value = element(tls_private_key.key.*.private_key_pem, 0)
}