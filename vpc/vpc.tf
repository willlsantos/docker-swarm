/*==== The VPC ======*/
resource "aws_vpc" "VPC_SWARM" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "VPC SWARM"
  }
}
/*==== Subnets ======*/
resource "aws_subnet" "Public_subnet_SWARM" {
  vpc_id                  = aws_vpc.VPC_SWARM.id
  cidr_block              = var.publicsCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "Public subnet Docker Swarm"
  }
}

/*==== Public ACL ======*/
resource "aws_network_acl" "Public_NACL_SWARM" {
  vpc_id     = aws_vpc.VPC_SWARM.id
  subnet_ids = [aws_subnet.Public_subnet_SWARM.id]
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.publicdestCIDRblock
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.publicdestCIDRblock
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Public NACL SWARM"
  }
}
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "IGW_SWARM" {
  vpc_id = aws_vpc.VPC_SWARM.id
  tags = {
    Name = "Internet gateway Docker Swarm"
  }
}
/*==== Route table ======*/
resource "aws_route_table" "Public_RT_SWARM" {
  vpc_id = aws_vpc.VPC_SWARM.id
  tags = {
    Name = "Public Route table KONG"
  }
}
resource "aws_route" "internet_access_KONG" {
  route_table_id         = aws_route_table.Public_RT_SWARM.id
  destination_cidr_block = var.publicdestCIDRblock
  gateway_id             = aws_internet_gateway.IGW_SWARM.id
}
resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.Public_subnet_SWARM.id
  route_table_id = aws_route_table.Public_RT_SWARM.id
}