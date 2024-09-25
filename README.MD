# AWS VPC and Networking Infrastructure

This Terraform configuration creates a Virtual Private Cloud (VPC) along with associated subnets (public, private, and database), an Internet Gateway (IGW), a NAT Gateway, and a Database Subnet Group for RDS in AWS. This setup is suitable for environments requiring both public-facing and private instances, such as a three-tier architecture setup.

## Resources Created
The following resources are provisioned:

1. **VPC (Virtual Private Cloud)**:
   - A VPC named `main` is created with a specified CIDR block.
   - DNS hostnames are enabled as per the variable configuration.

2. **Internet Gateway (IGW)**:
   - An Internet Gateway is associated with the VPC for enabling internet access for public subnets.

3. **Public Subnets**:
   - Public subnets are created in multiple Availability Zones (AZs) for high availability.
   - Instances launched in these subnets will have public IPs, enabling direct access to the internet.

4. **Private Subnets**:
   - Private subnets are created in the same AZs as the public subnets.
   - These subnets are not directly accessible from the internet but can connect to the internet via a NAT Gateway.

5. **Database Subnets**:
   - Additional subnets are created for database instances, ensuring separation of concerns for better security and organization.

6. **DB Subnet Group**:
   - A DB subnet group is created by grouping the database subnets, required for creating RDS instances.

7. **NAT Gateway**:
   - A NAT Gateway is created in the public subnet to allow outbound internet access from instances in the private subnets.
   - The NAT Gateway is associated with an Elastic IP (EIP).

## File Overview

- **`main.tf`**: This file contains the core Terraform code that provisions the VPC and associated resources.

### Variables Used
Make sure the following variables are defined either in a separate `variables.tf` file or passed via a `terraform.tfvars` file:

- `vpc_cidr`: The CIDR block for the VPC.
- `enable_dns_hostnames`: Boolean to enable/disable DNS hostnames in the VPC.
- `public_subnet_cidrs`: List of CIDR blocks for public subnets.
- `private_subnet_cidrs`: List of CIDR blocks for private subnets.
- `database_subnet_cidrs`: List of CIDR blocks for database subnets.
- `common_tags`: A map of common tags to apply to all resources.
- `vpc_tags`: Specific tags for the VPC.
- `igw_tags`: Specific tags for the Internet Gateway.
- `public_subnet_tags`: Specific tags for public subnets.
- `private_subnet_tags`: Specific tags for private subnets.
- `database_subnet_tags`: Specific tags for database subnets.
- `db_subnet_group_tags`: Specific tags for the DB subnet group.
- `nat_gateway_tags`: Specific tags for the NAT Gateway.
- `az_names`: List of availability zones where subnets will be created.

### Outputs
You may want to add output variables to capture important data, such as VPC ID, subnet IDs, and NAT Gateway ID for later use.

### Dependencies
The NAT Gateway depends on the Internet Gateway to be successfully created. The `depends_on` statement ensures that resources are created in the proper order.

## Instructions to Use

1. **Initialize Terraform**:
   Run the following command to initialize the working directory and download necessary providers:
   terraform init
   terraform plan 
   terraform apply -auto-approve 
   terraform destroy -auto-approve
