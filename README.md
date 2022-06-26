# Mandatory Terraform Task

### 1. FIrstly I've created AWS user for Terraform with Administrative access in IAM.
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture1.png)

### 2. I created a folder for Terraform tasks and created main.tf file inside the folder.
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture2.png)

### 3. After that in main.tf I wrote Terraform code which create in aws two EC2 instances Ubuntu and CentOS.
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture3.png)

<pre>
provider "aws" {
  region     = "eu-west-1"
}

# Create Ubuntu instance
resource "aws_instance" "my_Ubuntu" {
  ami           = "ami-0d75513e7706cf2d9"
  instance_type = "t2.micro"
  key_name = "open_ssh"
  tags = {
    Name    = "My Ubuntu Server"
    Owner   = "Uvaysjon Kholboev"
    Project = "Terraform Tasks"
  }
}


# Create CentOS instance
resource "aws_instance" "my_CentOS" {
  ami           = "ami-0babc7cb0024fd1f7"
  instance_type = "t2.micro"
  key_name = "open_ssh"
  tags = {
    Name    = "My CentOS"
    Owner   = "Uvaysjon Kholboev"
    Project = "Terraform Tasks"
  }
}

</pre>


### 4. I wrote additional script to create security groups for Ubuntu and CentOS instances:
1)To allow Internet EC2 Ubuntu with incoming access: ICMP, TCP/22, 80, 443, and any outgoing acces.<br>
2)To not allow Interet access EC2 CentOS, with outgoing and incoming access: ICMP, TCP/22, TCP/80, TCP/443 only on the local network where EC2 Ubuntu, EC2 CentOS is located.<br>

<pre>
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
</pre>

### 5. To attach security groups with instances I've used below script:

<pre>
vpc_security_group_ids = [aws_security_group.my_CentOS.id]
</pre>



### 6. After that I wrote additional script to install apache web server and create a web page with the text “Hello World” and information about the current version of the operating system.<br>

I’ve created shell script install.sh to install Apache Web Server and Docker and connected them with user_data = file(install.sh)

### install.sh

<pre>
<code>
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
sudo rm -r /var/www/html/index.html
system=`hostnamectl`
sudo echo "[html code]((https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture4.png))" >> /usr/share/nginx/html/index.html
sudo systemctl start apache2
sudo apt-get update
sudo apt-get install \
     ca-certificates \
     curl \
     gnupg \
     lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo apt-get install docker-ce=5:20.10.16~3-0~ubuntu-jammy docker-ce-cli=5:20.10.16~3-0~ubuntu-jammy containerd.io docker-compose-plugin -y
docker --version
</code>
</pre>

![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture5.png)

### 7. Final Terraform script:

<pre>
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
  tags = {
    Name    = "My Ubuntu Server"
    Owner   = "Uvaysjon Kholboev"
    Project = "Terraform Tasks"
  }
  vpc_security_group_ids = [aws_security_group.my_Ubuntu.id]
  user_data = file("install.sh")

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
</pre>

### 9. I created file with output terraform plan BEFORE creating infrastructure

<pre>
terraform init
terraform plan
</pre>

### [Output file](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/terraform_task_3/terraform_plan.txt)

![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture6.png)
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture7.png)


### 8. In order to create and apply infrastructure I’ve used below commands:

<pre>
terraform apply
</pre>

![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture8.png)
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture9.png)
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture10.png)
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture11.png)

### 9. Apache Web server installed and html web page is appeared.
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture12.png)

### 10. I connected to Ubuntu Server through ssh.
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture12.png)

### 11. As we know we created security group for to CentOS to not have access to the Internet but only for local network, so that's why when I try to connect throug my ip i got error Connection timed out. But when I connect throug My Ubuntu Server I've connected
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture13.png)
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture14.png)
![alt text](https://github.com/uvaysjon-coder/terraform_task_3/blob/main/screenshots/Picture15.png)








