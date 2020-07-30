output "servers" {
  value = [
    for index, id in hcloud_server.servers.*.id: {
      id   = id
      name = hcloud_server.servers[index].name
      type = hcloud_server.servers[index].server_type
      ipv4_address = hcloud_server.servers[index].ipv4_address
      location = hcloud_server.servers[index].location
      datacenter = hcloud_server.servers[index].datacenter
    }
  ]
}

output "ignition" {
  value = data.ignition_config.config.*.rendered
}
