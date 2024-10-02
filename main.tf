
# Creation of VPC 
resource "aws_vpc" "main"{                      
    cidr_block  = var.vpc_cidr    # this we have declared in variables 
    enable_dns_hostnames = var.enable_dns_hostnames  
    # this should be true and we have declared in variables as default value 

    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name    # expense-dev
        }
    )
}

# Creation of Internet gateway 
resource "aws_internet_gateway" "main"{    
    vpc_id = aws_vpc.main.id     # here we are taking the VPC id from which we have created earlier

    tags = merge (
        var.common_tags,
        var.igw_tags,
        {
            Name = local.resource_name      # expense-dev
        }
    )
}

# Now we have to Create subnets as per our requirement 
/*
1. public subnet 
2. private subnet
3. database subnet 
*/

# Creation of public subnet 
resource "aws_subnet" "public"{
    count = length(var.public_subnet_cidrs)    
    # we are specifying the condition as 2, that we have declared in variables 
    vpc_id  = aws_vpc.main.id    # here we are taking the VPC id from which we have created earlier
    cidr_block = var.public_subnet_cidrs[count.index]   # It will iterate over the cidr count (eg., 0, 1)
    availability_zone = local.az_names[count.index]  # Iterate and gives the two availability zones
    map_public_ip_on_launch = true     
    # it is true, becoz public subnet has internet gateway which directs to internet access
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
    # we are specifying the condition as 2, that we have declared in variables 
    vpc_id  = aws_vpc.main.id   # here we are taking the VPC id from which we have created earlier
    cidr_block = var.private_subnet_cidrs[count.index]  # It will iterate over the cidr count (eg., 0, 1)
    availability_zone = local.az_names[count.index]   # Iterate and gives the two availability zones

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
    # we are specifying the condition as 2, that we have declared in variables 
    vpc_id  = aws_vpc.main.id    # here we are taking the VPC id from which we have created earlier
    cidr_block = var.database_subnet_cidrs[count.index] # It will iterate over the cidr count (eg., 0, 1)
    availability_zone = local.az_names[count.index]  # Iterate and gives the two availability zones
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
    name = local.resource_name   # expense-dev
    subnet_ids = aws_subnet.database[*].id   # Here, we are adding the database subnets ids into a group 

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

    tags = {
        Name = "${local.resource_name}-eip"   # expense-dev-eip
    }
}

# creation of NAT gateway
resource "aws_nat_gateway" "main"{
    allocation_id  = aws_eip.nat.id    # we are allocating the elastic IP id 
    subnet_id = aws_subnet.public[0].id   # we are taking zero index value of public subnet id

    tags = merge(
        var.common_tags,
        var.nat_gatway_tags,
        {
            Name = local.resource_name   # expense-dev
        }
    )
    # To ensure proper ordering, it is recommended to add an explicit dependency 
    # on the Internet gateway for the vpc 
    depends_on = [aws_internet_gateway.main]  # NAT gateway depends on internet gateway
}

# Now we have to create route tables
/*
1. public route table
2. private route table
3. database route table
*/

# Creation of public route table 
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id   # here we are taking the VPC id from which we have created earlier

    tags = merge (
        var.common_tags,
        var.public_route_table_tags,
        {
            Name = "${local.resource_name}-public"  # expense-dev-public
        }
    )
}

# Creation of private route table 
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id   # here we are taking the VPC id from which we have created earlier

    tags = merge (
        var.common_tags,
        var.private_route_table_tags,
        {
            Name = "${local.resource_name}-private"  # expense-dev-private
        }
    )
}

# Creation of database route table 
resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id  # here we are taking the VPC id from which we have created earlier

    tags = merge (
        var.common_tags,
        var.database_route_table_tags,
        {
            Name = "${local.resource_name}-database"  # expense-dev-database
        }
    )
}

# we are going to add rules to Routes 
#difference between public route table and private route table - Internet access
# connection between internet gateway and public route tables
resource "aws_route" "public"{
    route_table_id = aws_route_table.public.id 
    destination_cidr_block = "0.0.0.0/0"   # This cidr is for internet access 
    gateway_id = aws_internet_gateway.main.id 
}

# connection between NAT gateway and private route table
resource "aws_route" "private_nat"{
    route_table_id = aws_route_table.private.id   # we are taking private route table id
    destination_cidr_block = "0.0.0.0/0"  # This cidr is for internet access 
    nat_gateway_id = aws_nat_gateway.main.id 
}

# connection between NAT gateway and database route table
resource "aws_route" "database_nat"{
    route_table_id = aws_route_table.database.id  # we are taking database route table id
    destination_cidr_block = "0.0.0.0/0"  # This cidr is for internet access 
    nat_gateway_id = aws_nat_gateway.main.id 
}

/*Now, We have to associate route tables with subnets*/
# public route table association
resource "aws_route_table_association" "public"{
    count = length(var.public_subnet_cidrs)   # Here the count we have taken is 2 
    subnet_id = aws_subnet.public[count.index].id # It iterate over public subnet ids 
    route_table_id = aws_route_table.public.id   # public route table id 
}

# private route table association
resource "aws_route_table_association" "private"{
    count = length(var.private_subnet_cidrs)   # Here the count we have taken is 2 
    subnet_id = aws_subnet.private[count.index].id  # It iterate over private subnet ids 
    route_table_id = aws_route_table.private.id # private route table id
}

# database route table association
resource "aws_route_table_association" "database"{
    count = length(var.database_subnet_cidrs)  # Here the count we have taken is 2 
    subnet_id = aws_subnet.database[count.index].id  # It iterate over database subnet ids 
    route_table_id = aws_route_table.database.id    # database route table id 
}