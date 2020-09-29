output "ca" {
  value = module.ca
}

output "front-proxy" {
  value = module.front-proxy
}

output "kubeconfig" {
  value = {
    admin = templatefile(format("%s/templates/kubeconfig.conf.tpl", path.module),
          merge(local.template_vars, local.kubeconfig_data["admin"]))
    bootstraper = templatefile(format("%s/templates/kubeconfig.conf.tpl", path.module),
          merge(local.template_vars, local.kubeconfig_data["bootstrapper"]))
  }
}

output "ignition" {
  value = {
    master = data.ignition_config.master
    worker = data.ignition_config.worker
  }
}

output "ignition_append" {
  value = {
    master = {
      source = format("%s://%s/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                      aws_s3_bucket_object.ignition-master.key)
      verification = format("%s-%s", "sha256", sha256(data.ignition_config.master.rendered))
    }
    worker = {
      source = format("%s://%s/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                      aws_s3_bucket_object.ignition-worker.key)
      verification = format("%s-%s", "sha256", sha256(data.ignition_config.worker.rendered))
    }

  }
}