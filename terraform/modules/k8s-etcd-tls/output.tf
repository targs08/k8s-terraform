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
    master = {
      rendered = data.ignition_config.config.rendered
    }
  }
}

output "ignition_append" {
  value = {
    source = format("%s://%s/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                        aws_s3_bucket_object.ignition.key)
    verification = format("%s-%s", "sha256", sha256(data.ignition_config.config.rendered))
  }
}

//output "ignition_append" {
//  value = {
//    source = format("data:text/plain;charset=utf-8;base64,%s", base64encode(data.ignition_config.config.rendered))
//    verification = ""
//  }
//}
