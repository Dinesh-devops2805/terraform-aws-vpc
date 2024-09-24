
# creation of VPC 
resource "aws_vpc" "main"{                      # VPC name is "main"
    cidr_block  = var.vpc_cidr
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name    # expense-dev
        }
    )
}

# Creation of Internet gateway 
resource "aws_internet_gateway" "main"{    # Internet gateway name is "main"
    vpc_id = aws_vpc.main.id 

    tags = merge (
        var.common_tags,
        var.igw_tags,
        {
            Name = local.resource_name      # expense-dev
        }
    )
}

# Creation of public subnet 
resource "aws_subnet" "public"{
    count = length(var.public_subnet_cidrs)
    vpc_id  = aws_vpc.main.id 
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true     # it is true, becoz public subnet has internet gateway which directs to internet access
    tags = merge(
        var.common_tags,
        var.public_subnet_tags,
        {   
            # expense-dev-public-us-east-1a and expense-dev-public-us-east-1b
            Name = "${local.resource_name}-public-${local.az_names[count.index]}"    
        }
    )
}

# Creation of private subnet 
resource "aws_subnet" "private"{
    count = length(var.private_subnet_cidrs)
    vpc_id  = aws_vpc.main.id 
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]

    tags = merge(
        var.common_tags,
        var.private_subnet_tags,
        {
             # expense-dev-private-us-east-1a and expense-dev-private-us-east-1b
            Name = "${local.resource_name}-private-${local.az_names[count.index]}"
        }
    )
}

# Creation of database subnet
resource "aws_subnet" "database"{
    count = length(var.database_subnet_cidrs)
    vpc_id  = aws_vpc.main.id 
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    tags = merge(
        var.common_tags,
        var.database_subnet_tags,
        {
             # expense-dev-database-us-east-1a and expense-dev-database-us-east-1b
            Name = "${local.resource_name}-database-${local.az_names[count.index]}"
        }
    )
}


# DB subnet group for RDS - adding all database subnets under one group 
resource "aws_db_subnet_group" "main" {
    name = local.resource_name
    subnet_ids = aws_subnet.database[*].id 

    tags = merge(
        var.common_tags,
        var.db_subnet_group_tags,
        {
            Name = local.resource_name   # expense-dev
        }
    )
}

# creation of elastic ip 
resource "aws_eip" "nat"{
    domain  = "vpc"
}

# creation of NAT gateway
resource "aws_nat_gateway" "main"{
    allocation_id  = aws_eip.nat.id 
    subnet_id = aws_subnet.public[0].id 

    tags = merge(
        var.common_tags,
        var.nat_gatway_tags,
        {
            Name = local.resource_name   # expense-dev
        }
    )
    # To ensure proper ordering, it is recommended to add an explicit dependency 
    # on the Internet gateway for the vpc 
    depends_on = [aws_internet_gateway.main]
}