locals {
  k8s_pki_dir = "/etc/kubernetes/pki"

  tls_files = concat(local.tls_common_files, length(var.nodes) > 0 ? [] : local.tls_node_files )

  tls_common_files = [
    {
      name = "apiserver-etcd-client.crt"
      content = module.apiserver-client.cert_pem
    },
    {
      name = "apiserver-etcd-client.key"
      content = module.apiserver-client.private_key_pem
    },
    {
      name = "etcd/ca.crt"
      content = module.ca.cert_pem
    },
//    {
//      name = "etcd/ca.key"
//      content = module.ca.private_key_pem
//    },
    {
      name = "etcd/healthcheck-client.crt"
      content = module.healthcheck-client.cert_pem
    },
    {
      name = "etcd/healthcheck-client.key"
      content = module.healthcheck-client.private_key_pem
    },
  ]
  tls_node_files = [
    {
      name = "etcd/node.crt"
      content = try(module.etcd.0.cert_pem, "")
    },
    {
      name = "etcd/node.key"
      content = try(module.etcd.0.private_key_pem, "")
    },
  ]

}

data "ignition_file" "tls" {
    count = length(local.tls_files)
    path = format("%s/%s", local.k8s_pki_dir, local.tls_files[count.index].name)
    mode = split(".",local.tls_files[count.index].name)[1] == "key" ? 384 : 420
    source {
      source = format("%s://%s/%s/tls/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                  var.s3.path, local.tls_files[count.index].name)
      verification = format("%s-%s", "sha256", sha256(local.tls_files[count.index].content))
    }
}

data "ignition_file" "tls-nodes-crt" {
    count = length(var.nodes)
    path = format("%s/%s", local.k8s_pki_dir, "etcd/node.crt")
    mode = 420
    source {
      source = format("%s://%s/%s/tls/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                  var.s3.path, format("etcd/%s.crt", element(var.nodes, count.index)))
      verification = format("%s-%s", "sha256", sha256(element(module.etcd-node.*.cert_pem, count.index)))
    }
}

data "ignition_file" "tls-nodes-key" {
    count = length(var.nodes)
    path = format("%s/%s", local.k8s_pki_dir, "etcd/node.key")
    mode = 384
    source {
      source = format("%s://%s/%s/tls/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                  var.s3.path, format("etcd/%s.key", element(var.nodes, count.index)))
      verification = format("%s-%s", "sha256", sha256(element(module.etcd-node.*.private_key_pem, count.index)))
    }
}

data "ignition_systemd_unit" "etcd" {
  name = "etcd.service"
  dropin {
    name = "10-member.conf"
    content = templatefile(format("%s/templates/etcd-member.service", path.module), local.etcd_bootstrap_vars)
  }
}

data "ignition_config" "common" {
  files = data.ignition_file.tls.*.rendered
  systemd = [
    data.ignition_systemd_unit.etcd.rendered
  ]
}

data "ignition_config" "nodes" {
  count = length(var.nodes)

  merge {
    source = format("data:text/plain;charset=utf-8;base64,%s", base64encode(data.ignition_config.common.rendered))
    verification = ""
  }

  files = [
    element(data.ignition_file.tls-nodes-crt.*.rendered, count.index),
    element(data.ignition_file.tls-nodes-key.*.rendered, count.index),
  ]
}


//data "ignition_file" "apiserver-client-cert" {
//    path = format("%s/apiserver-etcd-client.crt", local.k8s_pki_dir)
//    mode = 0644
//    source {
//      source = format("data:,%s", module.apiserver-client.cert_pem)
//    }
//}
//
//data "ignition_file" "apiserver-client-key" {
//    path = format("%s/apiserver-etcd-client.key", local.k8s_pki_dir)
//    mode = 0644
//    source {
//      source = format("data:,%s", module.apiserver-client.private_key_pem)
//    }
//}
//
//
//data "ignition_file" "ca" {
//    path = format("%s/etcd/ca.crt", local.k8s_pki_dir)
//    mode = 0644
//    source {
//      source = format("data:,%s", module.ca.cert_pem)
//    }
//}
//
//data "ignition_file" "healthcheck-client-cert" {
//    path = format("%s/etcd/healthcheck-client.crt", local.k8s_pki_dir)
//    mode = 0644
//    source {
//      source = format("data:,%s", module.healthcheck-client.cert_pem)
//    }
//}
//
//data "ignition_file" "healthcheck-client-key" {
//    path = format("%s/etcd/healthcheck-client.key", local.k8s_pki_dir)
//    mode = 0644
//    source {
//      source = format("data:,%s", module.healthcheck-client.private_key_pem)
//    }
//}
