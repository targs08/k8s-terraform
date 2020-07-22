provider "aws" {
  region  = var.region
}

module "ignition" {
  source = "./modules/k8s-ignition"
  provider_name = "aws"
}

module "aws-fcos" {
  source = "./modules/aws-ec2-fcos"
  name = var.name
  subnet_id = var.subnet_id
  config = var.config
  key_name = var.key_name
  user_data = module.ignition.rendered
}