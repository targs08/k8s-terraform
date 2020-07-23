locals {
  k8s_pki_dir = "/etc/kubernetes/pki"

  tls_files = [
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
    {
      name = "etcd/healthcheck-client.crt"
      content = module.healthcheck-client.cert_pem
    },
    {
      name = "etcd/healthcheck-client.key"
      content = module.healthcheck-client.private_key_pem
    },
  ]
}

data "ignition_file" "tls" {
    count = length(local.tls_files)
    path = format("%s/%s", local.k8s_pki_dir, local.tls_files[count.index].name)
    mode = split(".",local.tls_files[count.index].name)[1] == "key" ? 384 : 420
    source {
      source = format("s3://%s/%s/tls/%s", var.s3.bucket, var.s3.path, local.tls_files[count.index].name)
    }
}

data "ignition_config" "config" {
  files = data.ignition_file.tls.*.rendered
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
