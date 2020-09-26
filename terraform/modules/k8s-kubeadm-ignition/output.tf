output "ca" {
  value = module.ca
}

output "front-proxy" {
  value = module.front-proxy
}

output "kubeconfig" {
  value = templatefile(format("%s/templates/kubeconfig.conf.tpl", path.module), local.template_vars)
}

output "ignition" {
  value = data.ignition_config.common
}

output "ignition_append" {
  value = {
      source = format("%s://%s/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                      aws_s3_bucket_object.ignition.key)
      verification = format("%s-%s", "sha256", sha256(data.ignition_config.common.rendered))
  }
}