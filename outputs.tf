output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the created VPC"
}


output "az_info" {
  value = data.aws_availability_zones.available
}

output "default_vpc_info" {
  value = data.aws_vpc.default
}

output "default_vpc_route_table_info" {
  value = data.aws_route_table.main
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
