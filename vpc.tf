resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge (
    var.common_tags,
    var.vpc_tags,
    {
      Name = "${var.project_name}-${var.environment}"
    }
  )
}     #after this we need to record the vpc_id, so we can do that by output function, we need vpc_id to create the igw

#we need get the availability zones as well for that we use the data source get the availability zones and we use slice functions for the two availability zones


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.igw_tags,
  {
    Name = "local.resource_name"
  }
  
  )
}


# now we need to create the subnets

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)                  #we use count function because we have two subnets in two availability zone, it will decide by iterations
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]         #write the varaiables public_subnet_cidrs in varaiables
  availability_zone = local.az_names[count.index]           #record the public_subnet_id in outputs
  map_public_ip_on_launch = true

  tags = merge (
    var.common_tags,
    var.public_subnets_tags,
    {
     Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

#we need to get the availability_zones, we can get that by data source

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]


  tags = merge (
    var.common_tags,
    var.private_subnets_tags,
    {
     Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]


  tags = merge (
    var.common_tags,
    var.database_subnets_tags,
    {
     Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}

#now create database subnet group

resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id              #subnet_id for database_subnet is used here, which we recorded in outputs

  tags = merge (
    var.common_tags,
    var.aws_db_subnet_group_tags,
    {
    Name = local.resource_name
    }
  )
}

#Next create NAT gate_way, for that we need elastic_ip

#creating elastic_ip.

resource "aws_eip" "nat" {
  domain   = "vpc"
}

#creating NAT Gateway

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id             #Outbound flow: EC2 in a private subnet sends traffic to the NAT Gateway through the route table, 
                                                      #and the NAT Gateway changes the source IP to its Elastic IP and sends it into its public subnet,
  tags = merge (                                      # where the route table forwards it to the Internet Gateway, which delivers it to the internet.
    var.common_tags,
    var.aws_nat_gateway_tags,
    {
    Name = local.resource_name
  }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#Creating rout_tables

#Creating Public_subnets_route_table, just only route tables, not routes

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  

  tags = merge (
    var.common_tags,
    var.public_route_table_tags,
    {
    Name = "${local.resource_name}-public"
    }
  )
}


#create private_route_table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  

  tags = merge (
    var.common_tags,
    var.private_route_table_tags,
    {
    Name = "${local.resource_name}-private"
    }
  )
}

#create database_route_table

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  
  

  tags = merge (
    var.common_tags,
    var.database_route_table_tags,
    {
    Name = "${local.resource_name}-database"
    }
  )
}


#Now create routes

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}

#Create private route

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.main.id
}


#create database route

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.main.id
}


#Now associate the route tables with subnet ids

#resource "aws_route_table_association" "public" {
  #subnet_id      = aws_subnet.public.id
  #route_table_id = aws_route_table.public.id
#}

#resource "aws_route_table_association" "public" {
  #gateway_id     = aws_internet_gateway.igw.id
  #route_table_id = aws_route_table.public.id
#}

#instead of writing two seperate blocks we can write in one single block

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id     = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id     = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id     = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
