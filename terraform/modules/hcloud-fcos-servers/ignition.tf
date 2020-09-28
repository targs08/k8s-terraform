locals {
  network_manager_files = tolist(fileset(format("%s/files/NetworkManager", path.module), "**"))
//  blank_ignition_config = format("data:text/plain;charset=utf-8;base64,%s", base64encode(data.ignition_config.blank.rendered))
}

data "ignition_config" "blank" { }

data "ignition_systemd_unit" "afterburn" {
  name = "afterburn.service"

  dropin {
    name = "10-hcloud.conf"
    content = file(format("%s/files/afterburn/10-hcloud.service", path.module))
  }
}

data "ignition_file" "network-manager" {
    count = length(local.network_manager_files)
    path = format("/etc/NetworkManager/%s", local.network_manager_files[count.index])
    overwrite = true
    mode = 384
    source {
      source = format("data:text/plain;charset=utf-8;base64,%s", base64encode(file(format("%s/files/NetworkManager/%s", path.module, local.network_manager_files[count.index]))))
    }
}


//data "ignition_file" "afterburn" {
//  path = "/opt/bin/afterburn-custom"
//  mode = 493
//  content {
//   content = file(format("%s/files/afterburn-custom.sh", path.module))
//  }
//}

data "ignition_file" "hostname" {
  count = local.instance_count
  path = "/etc/hostname"
  mode = 420
  source {
    source = format("data:,%s", format(var.name_pattern, count.index + 1, var.name))
  }
}

data "ignition_user" "core_user" {
    name = "core"
    ssh_authorized_keys = data.hcloud_ssh_key.keys.*.public_key
}

data "ignition_config" "config" {
  count = local.instance_count
  files = concat(
    [element(data.ignition_file.hostname.*.rendered, count.index)],
    data.ignition_file.network-manager.*.rendered
  )

  systemd = [data.ignition_systemd_unit.afterburn.rendered]
  users = [data.ignition_user.core_user.rendered]

  merge {
    source = var.ignition_append.source
    verification = var.ignition_append.verification
  }

  merge {
    source = var.ignition_append_node[count.index].source
    verification = var.ignition_append_node[count.index].verification
  }
}