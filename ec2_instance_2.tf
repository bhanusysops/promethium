resource "aws_instance" "ec2_instance" {
    ami = var.ami_id
    subnet_id = aws_subnet.private.id
    instance_type = "t2.micro"
    associate_public_ip_address = false
    source_dest_check           = false
    user_data = "${file("./userdata.sh")}"
    tags = {
        Name = "promethium"
    }
}


resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  depends_on                = [aws_internet_gateway.gw]
}


resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${aws_vpc.main.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, only resources with in VPC address are allowed to ssh ! 
        cidr_blocks = [aws_vpc.main.cidr_block]
    }
    tags = {
        Name = "ssh-allowed"
    }
}
