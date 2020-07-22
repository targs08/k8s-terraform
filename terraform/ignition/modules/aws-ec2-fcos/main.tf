
locals {
  # Fedora owner
  ami_owner = "125523088429"
  default_volume_size = 50
  instance_count = length(var.config)
  tags = {
    "Cluster" = var.name,
    "Type"    = "Kubernetes",
  }
}

data "aws_ami" "fcos_ami" {
  owners = [local.ami_owner]

  most_recent      = true

  filter {
    name   = "name"
    values = ["fedora-coreos-*"]
  }

  filter {
    name   = "description"
    values = [format("Fedora CoreOS %s *", var.fcos_channel)]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "instances" {
  count              = local.instance_count
  ami                = data.aws_ami.fcos_ami.id
  instance_type      = lookup(var.config[count.index], "type")
  subnet_id          = var.subnet_id
  key_name           = var.key_name
  user_data          = var.user_data
  tags               = merge({"Name" = format("n%s.%s", count.index + 1, var.name), "Role" = lookup(var.config[count.index], "role")}, local.tags)
  volume_tags        = merge(local.tags, {"Instance" = format("n%s.%s", count.index + 1, var.name)})

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new Fedore CoreOs Release
    # come out.
    ignore_changes = [ami]
  }

  root_block_device {
    volume_size = lookup(var.config[count.index], "volume_size", local.default_volume_size)
  }
}
