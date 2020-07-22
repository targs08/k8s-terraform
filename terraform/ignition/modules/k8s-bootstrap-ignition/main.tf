
provider "ignition" {
  version = "2.1.0"
}

locals {
  rootfs_files = tolist(fileset(format("%s/files", path.module), "**"))
  system-packages = [
    "ethtool",
    "ipset",
    "conntrack-tools",
  ]
  kubernetes-component = [
    "kubelet",
    "kubectl",
    "kubeadm",
  ]
}

data "template_file" "cni-install-service" {
  template = file(format("%s/templates/cni-install.service", path.module))

  vars = {
    ARCH = var.arch
    CNI_VERSION = var.versions.cni
  }
}

data "template_file" "etcd-service" {
  template = file(format("%s/templates/etcd.service", path.module))

  vars = local.afterburn[var.provider_name]
}

data "template_file" "kubelet-service" {
  template = file(format("%s/templates/kubelet.service", path.module))
}

data "template_file" "overlay-install-service" {
  template = file(format("%s/templates/overlay-install.service", path.module))

  vars = {
    packages = join(" ", concat(local.system-packages, var.packages))
  }
}

data "template_file" "selinux-permissive-service" {
  template = file(format("%s/templates/selinux-permissive.service", path.module))
}

data "ignition_file" "rootfs" {
    count = length(local.rootfs_files)
    path = format("/%s", local.rootfs_files[count.index])
    mode = 0644
    source {
      source = format("data:,%s", file(format("%s/files/%s", path.module, element(local.rootfs_files, count.index))))
    }
}

data "ignition_file" "crictl" {
    path = "/opt/bin/crictl"
    mode = 0755
    overwrite = true
    source {
        source = format("https://github.com/kubernetes-sigs/cri-tools/releases/download/%[1]s/crictl-%[1]s-linux-%[2]s.tar.gz",
                var.versions.crictl, var.arch)
        compression = "gzip"
    }
}

data "ignition_file" "kubernetes-component" {
  count = length(local.kubernetes-component)
  mode = 0755
  overwrite = true
  path = format("/opt/bin/%s", local.kubernetes-component[count.index])
  source {
    source = format("https://storage.googleapis.com/kubernetes-release/release/%s/bin/linux/%s/%s",
                                                      var.versions.kubernetes, var.arch, local.kubernetes-component[count.index])
  }
}


data "ignition_link" "crictl" {
  path = "/usr/local/bin/crictl"
  target = "/opt/bin/crictl"
  overwrite = true
  hard = false
}

data "ignition_link" "kubeadm" {
    path = "/usr/local/bin/kubeadm"
    target = "/opt/bin/kubeadm"
    overwrite = true
    hard = false
}

data "ignition_link" "kubectl" {
    path = "/usr/local/bin/kubectl"
    target = "/opt/bin/kubectl"
    overwrite = true
    hard = false
}


data "ignition_systemd_unit" "cni-install" {
  name = "cni-install.service"
  enabled = true
  content = data.template_file.cni-install-service.rendered
}

data "ignition_systemd_unit" "docker-service" {
  name = "docker.service"
  enabled = true
}

data "ignition_systemd_unit" "docker-socket" {
  name = "docker.socket"
  enabled = false
}

data "ignition_systemd_unit" "etcd" {
  name = "etcd.service"
  enabled = true
  content = data.template_file.etcd-service.rendered
}

data "ignition_systemd_unit" "kubelet" {
  name = "kubelet.service"
  enabled = true
  content = data.template_file.kubelet-service.rendered
}

data "ignition_systemd_unit" "overlay-install" {
  name = "overlay-install.service"
  enabled = true
  content = data.template_file.overlay-install-service.rendered
}

data "ignition_systemd_unit" "selinux-permissive-service" {
  name = "selinux-permissive.service"
  enabled = true
  content = data.template_file.selinux-permissive-service.rendered
}


data "ignition_directory" "kubernetes" {
  path = "/etc/kubernetes/pki/etcd"
}


data "ignition_config" "config" {
  directories = [data.ignition_directory.kubernetes.rendered]
  files = concat(
    data.ignition_file.kubernetes-component.*.rendered,
    [
        data.ignition_file.crictl.rendered,
    ])
  links = [
    data.ignition_link.crictl.rendered,
    data.ignition_link.kubeadm.rendered,
    data.ignition_link.kubectl.rendered,
  ]
  systemd = [
    data.ignition_systemd_unit.cni-install.rendered,
    data.ignition_systemd_unit.docker-service.rendered,
    data.ignition_systemd_unit.docker-socket.rendered,
    data.ignition_systemd_unit.etcd.rendered,
    data.ignition_systemd_unit.kubelet.rendered,
    data.ignition_systemd_unit.overlay-install.rendered,
    data.ignition_systemd_unit.selinux-permissive-service.rendered
  ]
}