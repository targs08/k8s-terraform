
locals {
  # Fedora owner
  ami_owner = "125523088429"
  tags = {
    "Name" = var.name
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

resource "aws_instance" "instance" {
  ami                = data.aws_ami.fcos_ami.id
  instance_type      = var.type
  subnet_id          = var.subnet_id
  key_name           = var.key_name
  user_data          = var.user_data
  tags               = merge(local.tags, var.tags)
  volume_tags        = merge(local.tags, {"Instance" = var.name}, var.tags)

  iam_instance_profile = var.instance_profile

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new Fedora CoreOs Release
    # come out.
    ignore_changes = [ami]
  }

  root_block_device {
    volume_size = var.volume_size
  }
}
