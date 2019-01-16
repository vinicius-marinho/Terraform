#-----networking/variables.tf-----

variable "vpc_cidr" {}

variable "public_cidrs" {
  type = "list"
}

variable "accessip" {}

// variable "private_cidrs" {
//     default = ["10.123.3.0/24", "10.123.4.0/24"]
// }

