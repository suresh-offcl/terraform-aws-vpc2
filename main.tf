# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.resource_name
    }
  )
}

# Create an Internet Gateway (IGW)
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
      Name = "${local.resource_name}_publicSubnet"
    }
  )
}

# Create Private Subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
      {
      Name = "${local.resource_name}_privateSubnet"
    }
  )
}

# Create Database Subnet
resource "aws_subnet" "database" {
  count = length((var.database_subnet_cidrs))
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
      {
      Name = "${local.resource_name}_databaseSubnet"
    }
  )
}

# Create an AWS DB Subnet Group for RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  count = length(var.database_subnet_cidrs)
  name       = "db-subnet-group"
  subnet_ids = aws_subnet.database[count.index].id  # Reference all database subnets

  tags = merge(
    var.common_tags,
    var.db_subnet_group_tags,
      {
      Name = "${local.resource_name}_databaseSubnetGroup"
    }
  )
}

# Create an Elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# Create a NAT Gateway using the EIP
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
    var.common_tags,
    var.nat_tags,
    {
      Name = "nat"
    }
  )
}

resource "aws_route" "public" {
  count = length(var.public_subnet_cidrs)
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  count = length(var.private_subnet_cidrs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route" "database" {
  count = length(var.database_subnet_cidrs)
  route_table_id         = aws_route_table.database[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
# Create a public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Create a Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

# Create a Private Route Table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "database-route-table"
  }
}

# Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with the Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate Database Subnets with the Database Route Table
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}



