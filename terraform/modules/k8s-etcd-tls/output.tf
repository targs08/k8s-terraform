output "ca" {
  value = module.ca
}

output "healthcheck-client" {
  value = module.healthcheck-client
}

output "apiserver-client" {
  value = module.apiserver-client
}

output "ignition" {
  value = {
    common = data.ignition_config.common
    nodes = data.ignition_config.nodes
  }
}

output "ignition_append" {
  value = {
    common = {
      source = format("%s://%s/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                      aws_s3_bucket_object.ignition.key)
      verification = format("%s-%s", "sha256", sha256(data.ignition_config.common.rendered))
    }
    nodes = length(var.nodes) > 0 ? [
      for index, value in var.nodes: {
        source = format("%s://%s/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                      element(aws_s3_bucket_object.ignition-nodes.*.key, index))
        verification = format("%s-%s", "sha256", sha256(element(data.ignition_config.nodes.*.rendered, index)))
      }
    ] : []
  }
}

//output "ignition_append" {
//  value = {
//    source = format("data:text/plain;charset=utf-8;base64,%s", base64encode(data.ignition_config.config.rendered))
//    verification = ""
//  }
//}
