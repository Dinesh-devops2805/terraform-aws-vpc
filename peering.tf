# creation of peering connection between two VPCs 
resource "aws_vpc_peering_connection" "peering"{
    count = var.is_peering_required ? 1 : 0   # If it is true - 1 or else if it is false - 0 
    vpc_id  = aws_vpc.main.id   #requestor - here our vpc is requesting to default vpc 
    peer_vpc_id  = data.aws_vpc.default.id  #acceptor - default vpc is accepting the connection from our vpc
    auto_accept = true   # we are aumatically accepting the connection 

    tags = merge (
        var.common_tags,
        var.vpc_peering_tags,
        {
            Name = "${local.resource_name}-default"   # expense-dev-default 
        }
    )
}

# establishing connection from requestor to acceptor 
resource "aws_route" "public_peering"{
    count = var.is_peering_required ? 1 : 0   # If it is true - 1 or else if it is false - 0 
    route_table_id  = aws_route_table.public.id   # public route table id 
    destination_cidr_block = data.aws_vpc.default.cidr_block  # This is going to take default cidr block 
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id  # peering connection id
}

# establishing connection from requestor to acceptor 
resource "aws_route" "private_peering"{
    count = var.is_peering_required ? 1 : 0   # If it is true - 1 or else if it is false - 0 
    route_table_id  = aws_route_table.private.id   # private route table id 
    destination_cidr_block = data.aws_vpc.default.cidr_block  # This is going to take default cidr block 
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id  # peering connection id
}

# establishing connection from requestor to acceptor 
resource "aws_route" "database_peering"{
    count = var.is_peering_required ? 1 : 0   # If it is true - 1 or else if it is false - 0 
    route_table_id  = aws_route_table.database.id   # database route table id 
    destination_cidr_block = data.aws_vpc.default.cidr_block   # This is going to take default cidr block 
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id # peering connection id
}

# establishing connection from acceptor to requestor 
resource "aws_route" "default_peering"{
    count = var.is_peering_required ? 1 : 0   # If it is true - 1 or else if it is false - 0 
    route_table_id  = data.aws_route_table.main.route_table_id # default route table id 
    destination_cidr_block = var.vpc_cidr  # "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id # peering connection id
}
