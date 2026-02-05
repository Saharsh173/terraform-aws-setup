
resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }
}


resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.demo-vpc.id
  tags = {
    Name="demo-igw"
  }
}

resource "aws_subnet" "public-subnets" {
  count = length(var.public_subnet)
  vpc_id = aws_vpc.demo-vpc.id
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  cidr_block = var.cidr_block[count.index]
   tags = {
    Name=var.public_subnet[count.index]
  }

}

resource "aws_subnet" "private-subnets" {
  count = length(var.private_subnet)
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = var.private_cidr_block[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name=var.private_subnet[count.index]
  }

}


resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.demo-vpc.id
  route  {
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.internet-gateway.id
    }
}
resource "aws_route_table_association" "public-rtb-association" {
  count = length(var.public_subnet)
  route_table_id = aws_route_table.public-rtb.id
  subnet_id = aws_subnet.public-subnets[count.index].id
}


resource "aws_eip" "nat-gw-ip" {
  domain="vpc"
}
resource "aws_nat_gateway" "regional-nat-gw" {
  allocation_id = aws_eip.nat-gw-ip.id
  subnet_id = aws_subnet.public-subnets[0].id
  connectivity_type = "public"
  
  tags = {
    Name="regional-nat-gateway"
  }
}

resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block="0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.regional-nat-gw.id
  }
}
resource "aws_route_table_association" "private-rtb-association" {
  count = length(var.private_subnet)
  subnet_id = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-rtb.id
}
