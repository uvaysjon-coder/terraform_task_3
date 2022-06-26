#--------------------------------------------
#
# My Terraform Tasks
#
# Uvaysjon Kholboev
#
#--------------------------------------------


provider "aws" {
  region = "eu-west-1"
}

# Create Ubuntu instance
resource "aws_instance" "my_Ubuntu" {
  ami           = "ami-0d75513e7706cf2d9"
  instance_type = "t2.micro"
  key_name      = "open_ssh"
  user_data = file("install.sh")
  tags = {
    Name    = "My Ubuntu Server"
    Owner   = "Uvaysjon Kholboev"
    Project = "Terraform Tasks"
  }
  vpc_security_group_ids = [aws_security_group.my_Ubuntu.id]
}

# Create CentOS instance
resource "aws_instance" "my_CentOS" {
  ami           = "ami-0babc7cb0024fd1f7"
  instance_type = "t2.micro"
  key_name      = "open_ssh"
  tags = {
    Name    = "My CentOS"
    Owner   = "Uvaysjon Kholboev"
    Project = "Terraform Tasks"
  }
  vpc_security_group_ids = [aws_security_group.my_CentOS.id]
}


resource "aws_security_group" "my_Ubuntu" {
  name        = "Ubuntu server security group"
  description = "EC2 Ubuntu incoming access throug Internet: ICMP, TCP/22, 80, 443, and any outgoing access"

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My_Ubuntu_Security_Group "
  }
}


resource "aws_security_group" "my_CentOS" {
  name        = "CentOS server security group"
  description = "EC2 CentOS incoming access through local network: ICMP, TCP/22, 80, 443, and any outgoing access"

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["172.31.0.0/16"]
    }
  }


  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["172.31.0.0/16"]
  }


  dynamic "egress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["172.31.0.0/16"]
    }
  }


  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  tags = {
    Name = "My_CentOS_Security_Group "
  }
}


