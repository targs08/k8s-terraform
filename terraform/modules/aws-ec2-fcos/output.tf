output "instances" {
  value = [
    for index, id in aws_instance.instances.*.id: {
      id   = id
      name = format("n%s.%s", index + 1, var.name)
      type = aws_instance.instances[index].instance_type
      ip = aws_instance.instances[index].private_ip
    }
  ]
}
