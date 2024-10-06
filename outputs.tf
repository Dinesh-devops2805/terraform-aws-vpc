output "vpc_id" {
  value = aws_vpc.main.id # we are going to print vpc id 
}

output "az_info" {
  value = data.aws_availability_zones.available # availability zones information 
}

output "default_vpc_info" {
  value = data.aws_vpc.default # default VPC information 
}

output "main_route_table_info" {
  value = data.aws_route_table.main # route table information 
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id # we going to print the output of two public subnet ids 
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id # we going to print the output of two private subnet ids 
}

output "database_subnet_ids" {
  value = aws_subnet.database[*].id # we going to print the output of two database subnet ids 
}

output "database_subnet_group_name" {
  value = aws_db_subnet_group.main.name # # we going to print the output of database subnet group name
}