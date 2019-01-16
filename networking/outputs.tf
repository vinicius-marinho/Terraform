#-----networking/outputs.tf-----
output "VPC_Name" {
  value = "${aws_vpc.tf_vpc.id}"
}

output "public_subnets" {
  value = "${aws_subnet.tf_public_subnet.*.id}"
}

output "public_sg" {
  value = "${aws_security_group.tf_public_sg.id}"
}

output "subnet_ips" {
  value = "${aws_subnet.tf_public_subnet.*.cidr_block}"
}
