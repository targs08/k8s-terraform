locals {
  k8s_dir = "/etc/kubernetes"
  k8s_pki_dir = "/etc/kubernetes/pki"

  k8s_kubeconfig_path = format("%s/admin.conf", local.k8s_dir)

  tls_files = [
    {
      name = "ca.crt"
      content = module.ca.cert_pem
    },
    {
      name = "ca.key"
      content = module.ca.private_key_pem
    },
    {
      name = "front-proxy-ca.crt"
      content = module.front-proxy.cert_pem
    },
    {
      name = "front-proxy-ca.key"
      content = module.front-proxy.private_key_pem
    },
    {
      name = "sa.key"
      content = tls_private_key.sa.private_key_pem
    },
    {
      name = "sa.pub"
      content = tls_private_key.sa.public_key_pem
    }
  ]

  kubeconfig_data = {
    admin = {
      KUBE_CLIENT_CERT_DATA = base64encode(module.kubernetes-admin.cert_pem)
      KUBE_CLIENT_KEY_DATA = base64encode(module.kubernetes-admin.private_key_pem)
    },
    bootstrapper = {
      KUBE_CLIENT_CERT_DATA = base64encode(module.kubernetes-bootstrapper.cert_pem)
      KUBE_CLIENT_KEY_DATA = base64encode(module.kubernetes-bootstrapper.private_key_pem)
    }
  }

  template_vars = {
    CLUSTER_NAME = var.cluster_name
    KUBE_CA_DATA = base64encode(module.ca.cert_pem)
    KUBE_CONTROL_PLANE_ENDPOINT = format("%s:%d", var.control_plane_host, 6443)
    KUBE_ETCD_ENDPOINTS = var.etcd_endpoints
    KUBECONFIG = local.k8s_kubeconfig_path

    KUBELET_CLOUD_PROVIDER = var.cloud_provider
    KUBELET_NETWORK_PLUGIN = var.network_plugin
  }
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

data "ignition_file" "tls-worker" {
    path = format("%s/%s", local.k8s_pki_dir, "ca.crt")
    mode = 384
    source {
      source = format("%s://%s/%s/tls/%s", var.s3.scheme, var.s3.scheme == "s3" ?
              data.aws_s3_bucket.bucket.bucket : data.aws_s3_bucket.bucket.bucket_domain_name,
                  var.s3.path, "ca.crt")
      verification = format("%s-%s", "sha256", sha256(module.ca.cert_pem))
    }
}

data "ignition_systemd_unit" "kubeadm-init" {
  name = "kubeadm.init.service"
  enabled = true
  content = templatefile(format("%s/templates/kubeadm.init.service", path.module), local.template_vars)
}

data "ignition_systemd_unit" "kubeadm-join" {
  name = "kubeadm.join.service"
  enabled = true
  content = templatefile(format("%s/templates/kubeadm.join.service", path.module), local.template_vars)
}

data "ignition_file" "kubeadm-config-join-master" {
  path = format("%s/kubeadm-config.yaml", local.k8s_dir)
  mode = 420
  content  {
    content = templatefile(format("%s/templates/kubeadm-config.control-plane.yaml.tpl", path.module), local.template_vars)
  }
}

data "ignition_file" "kubeadm-config-join-worker" {
  path = format("%s/kubeadm-config.yaml", local.k8s_dir)
  mode = 420
  content  {
    content = templatefile(format("%s/templates/kubeadm-config.join.yaml.tpl", path.module),
          merge(local.template_vars, {KUBECONFIG = format("%s/discovery.conf", local.k8s_dir)}))
  }
}

data "ignition_file" "kubeconfig-admin" {
  path = local.k8s_kubeconfig_path
  mode = 384
  content  {
    content = templatefile(format("%s/templates/kubeconfig.conf.tpl", path.module),
          merge(local.template_vars, local.kubeconfig_data["admin"]))
  }
}

data "ignition_file" "kubeconfig-bootstrapper" {
  path =  format("%s/discovery.conf", local.k8s_dir)
  mode = 384
  content  {
    content = templatefile(format("%s/templates/kubeconfig.conf.tpl", path.module),
          merge(local.template_vars, local.kubeconfig_data["bootstrapper"]))
  }
}

data "ignition_config" "master" {
  files = concat(data.ignition_file.tls.*.rendered, [
    data.ignition_file.kubeconfig-admin.rendered,
    data.ignition_file.kubeadm-config-join-master.rendered
  ])
  systemd = [
    data.ignition_systemd_unit.kubeadm-join.rendered
  ]
}

data "ignition_config" "worker" {
  files = [
    data.ignition_file.tls-worker.rendered,
    // TODO: remove
    data.ignition_file.kubeconfig-admin.rendered,

    data.ignition_file.kubeconfig-bootstrapper.rendered,
    data.ignition_file.kubeadm-config-join-worker.rendered
  ]
  systemd = [
    data.ignition_systemd_unit.kubeadm-join.rendered
  ]
}
