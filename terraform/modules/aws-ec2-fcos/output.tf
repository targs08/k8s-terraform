//output "instances" {
//  value = [
//    for index, id in aws_instance.instances.*.id: {
//      id   = id
//      name = format("n%s.%s", index + 1, var.name)
//      type = aws_instance.instances[index].instance_type
//      ip = aws_instance.instances[index].private_ip
//    }
//  ]
//}

output "id" {
  value = aws_instance.instance.id
}

output "name" {
  value = var.name
}

output "type" {
  value = var.type
}

output "ip" {
  value = aws_instance.instance.private_ip
}