
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "promethium"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_public_cidr
  tags = {
    Name = "Public"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id


  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table_association" "main_pub" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_private_cidr
  tags = {
    Name = "Private"
  }
}

resource "aws_route_table" "main_private" {
  vpc_id = aws_vpc.main.id
    
  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }



  tags = {
    Name = "Private"
  }
}

resource "aws_route_table_association" "main_pri" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.main_private.id
}
