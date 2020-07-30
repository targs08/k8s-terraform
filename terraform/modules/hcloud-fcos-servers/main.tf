locals {
  instance_count = length(var.config)
}

resource "tls_private_key" "bootstrap" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "hcloud_ssh_key" "bootstrap" {
  name = format("%s.bootstrap.unsecure", var.name)
  public_key = tls_private_key.bootstrap.public_key_openssh
  labels = {
    name = var.name
  }
}

data "hcloud_ssh_key" "keys" {
  count = length(var.ssh_keys)
  id = var.ssh_keys[count.index]
}

data "hcloud_locations" "locations" { }

resource "random_shuffle" "locations" {
  result_count = local.instance_count
  input = data.hcloud_locations.locations.names
}

data "hcloud_location" "location" {
  count = local.instance_count
  name = element(coalescelist(compact(var.config.*.location), random_shuffle.locations.result), count.index)
}

resource "hcloud_server" "servers" {
  count = local.instance_count
  name = format(var.name_pattern, count.index + 1, var.name)
  image = "fedora-32"
  rescue = "linux64"
  server_type = lookup(var.config[count.index], "type")
  ssh_keys = concat([hcloud_ssh_key.bootstrap.id], var.ssh_keys)
  location = element(data.hcloud_location.location.*.name, count.index)
  keep_disk = true
  labels = merge(
    var.labels,
    map("name", format(var.name_pattern, count.index + 1, var.name)),
    lookup(var.config[count.index], "labels")
  )

  connection {
    host = self.ipv4_address
    private_key = tls_private_key.bootstrap.private_key_pem
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "sysctl -w net.ipv6.conf.all.disable_ipv6=1",
      "sysctl -w net.ipv6.conf.default.disable_ipv6=1",
      "apt-get update",
      "apt-get install -y pkg-config libssl-dev",
      "curl https://sh.rustup.rs -sSf | sh -s -- -y",
      "~/.cargo/bin/cargo install coreos-installer",
    ]
  }

  provisioner "file" {
    when = create
    content = data.ignition_config.config[count.index].rendered
    destination = "/root/ignition.json"
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "~/.cargo/bin/coreos-installer install --append-karg net.ifnames=0 --ignition-file /root/ignition.json /dev/sda",
      "shutdown -r +1",
    ]
  }
}

