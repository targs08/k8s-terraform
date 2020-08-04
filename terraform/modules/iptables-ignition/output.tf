output "rendered" {
  value = data.ignition_config.config.rendered
}

output "ignition_append" {
  value = {
    source = format("data:text/plain;charset=utf-8;base64,%s", base64encode(data.ignition_config.config.rendered))
    verification = format("%s-%s", "sha256", sha256(data.ignition_config.config.rendered))
  }
}