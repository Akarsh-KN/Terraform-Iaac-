provider "aws" {
  region = "ap-south-1"
  access_key = "AAAAAAAAAAAAAAAAAA"
  secret_key = "ASHDFUSHKFJHSkasfjksdhfjksdfdjs"
}
#variable "subnet_prefix" {
#  description = "cider block for the subnet"
  # default = "10.0.66.0/24"
  
#}

# 1. Create VPC

resource "aws_vpc" "akarsh-1-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.akarsh-1-vpc.id
}

# 3. Create custom route tabele 

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.akarsh-1-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }
  route {
      ipv6_cidr_block = "::/0"
      gateway_id = aws_internet_gateway.gw.id
    }
  

  tags = {
    Name = "prod-route"
  }
}


# 4. Create a subnet

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.akarsh-1-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "prod-subnet"
  }
}


# 5. Association of route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}


# 6. Create a security group

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.akarsh-1-vpc.id

  ingress {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      
    }
  
  tags = {
    Name = "allow_tls"
  }
}


# 7. Create network interface

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_tls.id]

}

# 8. Create elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# 9. create ubuntu server

resource "aws_instance" "web-server-instance" {
  ami = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "web-server"
  }  
}



