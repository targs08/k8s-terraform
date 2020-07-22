
variable "name" {
  description = "Cluster name"
}

variable "region" {
  // TODO: use type=list when implement multi-region feature
  type = string
  default = "us-east-1"
  description = "AWS Region. Default: us-east-1"
}

variable "subnet_id" {
  description = "Subnet ID"
}

variable "key_name" {
  description = "Name of created key pair in AWS"
}


variable "config" {
  type = list(object({
    type = string
    role = string
    volume_size = string
  }))
  description = "List of options to generate instances"
}
