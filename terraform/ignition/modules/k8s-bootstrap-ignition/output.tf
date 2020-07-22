//locals {
//  v3_patch = jsonencode(merge(jsondecode(data.ignition_config.config.rendered), local.ignition_patch))
//}

output "rendered" {
  value = data.ignition_config.config.rendered
}

output "append" {
  value = {
    source = format("data:text/plain;charset=utf-8;base64,%s", base64encode(data.ignition_config.config.rendered))
    verification = ""
  }
}

output "data" {
  value = {
    directories = [data.ignition_directory.kubernetes.rendered]
    files = concat(
      data.ignition_file.kubernetes-component.*.rendered,
      data.ignition_file.rootfs.*.rendered,
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
      data.ignition_systemd_unit.selinux-permissive-service.rendered,
    ]
  }
}