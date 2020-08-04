
locals {
  config = {
    whitelist = var.cidr
    rules = var.rules
  }
}

data "ignition_systemd_unit" "iptables-restore" {
  name = "iptables-restore.service"
  enabled = true
  content = file(format("%s/files/iptables-restore.service", path.module))
}

data "ignition_file" "rules" {
  path = "/etc/sysconfig/iptables"
  overwrite = true
  content {
    content = templatefile(format("%s/templates/iptables.tpl", path.module), local.config)
  }
}

data "ignition_config" "config" {
  systemd = [
    data.ignition_systemd_unit.iptables-restore.rendered
  ]
  files = [
    data.ignition_file.rules.rendered
  ]
}