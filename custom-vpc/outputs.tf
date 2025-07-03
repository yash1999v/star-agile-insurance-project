output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_ips" {
  description = "Public IPs of EC2 instances"
  value       = [for instance in aws_instance.web : instance.public_ip]
}
