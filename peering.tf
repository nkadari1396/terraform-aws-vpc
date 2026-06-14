#creating a vpc_peering, first we need to write a variable is_peering required? in variable.tf file


resource "aws_vpc_peering_connection" "main_peering" {
  count = var.is_peering_required ? 1:0  
  #peer_owner_id = var.peer_owner_id, this is optional, as it is requestor (expense-dev vpc)
  peer_vpc_id   = data.aws_vpc.default.id # this is the acceptor(default vpc) and the requestor is expense-dev
  vpc_id        = aws_vpc.main.id


  auto_accept   = true

  #to get the default vpc_id we need to use the data source and use the output to store it

tags = merge (
    var.common_tags,
    var.vpc_peering_tags,

    {
    Name = "${local.resource_name}-default"
    }
)
}

#public peering 

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1:0  
  route_table_id            = aws_route_table.public.id # route table created in the vpc.tf 
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_peering[count.index].id
}


#private peering 

resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1:0  
  route_table_id            = aws_route_table.private.id # route table created in the vpc.tf 
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_peering[count.index].id
}

#public peering 

resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1:0  
  route_table_id            = aws_route_table.database.id # route table created in the vpc.tf 
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_peering[count.index].id
}

# now connections from expense-dev subnets has been confirmed to the expense-dev vpc, its time to establish
#connections from the default vpc

#public peering 

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1:0  
  #we didnt create any route_table for default_vpc, it can be get it by data_source.
  route_table_id            = data.aws_route_table.main.route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main_peering[count.index].id
}

