variable "aws_region" {
  description = "AWS Region"
}

variable "project_name" {
  description = "Name of the project"
}

variable "vpc_cidr" {}

variable "public_cidrs" {
  type = "list"
}

variable "accessip" {}

variable "key_name" {}

variable "public_key_path" {}

variable "server_instance_type" {}

variable "instance_count" {
  default = 1
}
