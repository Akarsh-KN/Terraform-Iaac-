provider "aws" {
  region = "ap-south-1"
  access_key = "AAAAAAAAAAAAAAAAAAAA"
  secret_key = "SDHFFFGDJGFHSDJGHDFJGDFHGFKHJHG"
}

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}



# resource "<provider>_<resource_type>" "name" {
#     config options
#     key = "value"
# }

#resource "aws_instance" "my-first-server" {
#  ami           = "ami-0c1a7f89451184c8b"
#  instance_type = "t2.micro"
  #tags = {
  #  Name = "ubuntu"
  #}
#}


