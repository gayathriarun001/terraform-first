
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "cicd" {
    ami =  "ami-01816d07b1128cd2d"
    instance_type = "t2.micro"
    key_name = "ddp"
    #security_group = "cicd_sg"
    vpc_security_group_ids = [aws_security_group.cicd_sg.id]
    subnet_id = aws_subnet.cicd-public-subnet-01.id
}
 
resource "aws_security_group" "cicd_sg" {
    name = "cicd_sg"
    description = "ssh access"
    vpc_id = aws_vpc.cicd-vpc.id
    ingress {
      description   = "ssh access"
      from_port     = 22
      to_port       = 22
      protocol      = "tcp"
      cidr_blocks   = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "ssh-port"
    }
}

resource "aws_vpc" "cicd-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "cicd-vpc"
  }
}
 
resource "aws_subnet" "cicd-public-subnet-01" {
  vpc_id = aws_vpc.cicd-vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "cicd-public-subnet-01"
  }
}

resource "aws_subnet" "cicd-public-subnet-02" {
  vpc_id = aws_vpc.cicd-vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "cicd-public-subnet-02"
  }
}

resource "aws_internet_gateway" "cicd-igw" {
  vpc_id = aws_vpc.cicd-vpc.id
  tags = {
    Name = "cicd-igw"
  }
}

resource "aws_route_table" "cicd-public-rt" {
  vpc_id = aws_vpc.cicd-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cicd-igw.id
  }
}

resource "aws_route_table_association" "cicd-rta-public-subnet-01" {
  subnet_id = aws_subnet.cicd-public-subnet-01.id
  route_table_id = aws_route_table.cicd-public-rt.id
} 

resource "aws_route_table_association" "cicd-rta-public-subnet-02" {
  subnet_id = aws_subnet.cicd-public-subnet-02.id
  route_table_id = aws_route_table.cicd-public-rt.id
}  


