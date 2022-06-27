#----------------------------------------
# My Terraform Extra Task
#
# Uvaysjon Kholboev
#
#----------------------------------------

provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "latest_centOS" {
  owners      = ["679593333241"]
  most_recent = true
  filter {
    name   = "name"
    values = ["CentOS-7-*.x86_64-d9a3032a-921c-4c6d-b150-bde168105e42"]
  }
}

# Create Ubuntu instance
resource "aws_instance" "my_Ubuntu" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  key_name      = "open_ssh"
  tags = {
    Name    = "My Ubuntu Server"
    Owner   = "Uvaysjon Kholboev"
    Project = "Terraform Tasks"
  }
  vpc_security_group_ids = [aws_security_group.my_Ubuntu.id]
}

# Create CentOS instance
resource "aws_instance" "my_CentOS" {
  ami           = data.aws_ami.latest_centOS.id
  instance_type = "t2.micro"
  key_name      = "open_ssh"
  user_data = file("install.sh")
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
      cidr_blocks = ["52.51.231.151/32"]
    }
  }


  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["52.51.231.151/32"]
  }


  dynamic "egress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["52.51.231.151/32"]
    }
  }


  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["52.51.231.151/32"]
  }

  tags = {
    Name = "My_CentOS_Security_Group "
  }
}

output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}

output "latest_ubuntu_ami_name" {
  value = data.aws_ami.latest_ubuntu.name
}

output "latest_centOS_ami_id" {
  value = data.aws_ami.latest_centOS.id
}

output "latest_centOS_ami_name" {
  value = data.aws_ami.latest_centOS.name
}
