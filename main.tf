# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true 

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.resource_name
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
    Name = local.resource_name
  }
  )
}

# Create Public Subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
        Name = "${local.resource_name}-public_subnet"
    }
  )
}

# Create private Subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
        Name = "${local.resource_name}-private_subnet"
    }
  )
}

# Create database Subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
        Name = "${local.resource_name}-database_subnet"
    }
  )
}

resource "aws_db_subnet_group" "db_subnet_group" {
  
  subnet_ids = aws_subnet.database[*].ip 
  
  tags = merge(
    var.common_tags,
    var.db_group_tags,
    {
        Name = local.resource_name
    }
  )
}


#create elastic ipaddress
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.common_tags,
    var.eip_tags,
    {
        Name = "${local.resource_name}-eip"
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on = [aws_internet_gateway.igw]

}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id  
   
  tags = merge(
    var.common_tags,
    var.aws_routeTable_publicTags,
    {
        Name = "${local.resource_name}-public"
    }
  )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id  
   
  tags = merge(
    var.common_tags,
    var.aws_routeTable_privateTags,
    {
        Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id  
   
  tags = merge(
    var.common_tags,
    var.aws_routeTable_databaseTags,
    {
        Name = "${local.resource_name}-database"
    }
  )
}

resource "aws_route" "public" {
  count = length(var.public_subnet_cidrs)
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private" {

  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "database" {

  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id 
  route_table_id = aws_route_table.database.id

}


