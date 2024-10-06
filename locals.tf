locals {
  resource_name = "${var.project_name}-${var.environment}" # expense-dev
  az_names      = slice(data.aws_availability_zones.available.names, 0, 2)
  # Here we are taking two availability zones (eg., us-east-1a, us-east-1b)
}