# VPC Configuration
resource "aws_vpc" "test-vpc" {
cidr_block = "10.0.0.0/16"
tags = {
  Name = "test-vpc"
  }
}

# Subnet Configuration
  resource "aws_subnet" "test-public-subnet" {
  vpc_id = aws_vpc.test-vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true" 
  tags = {
  Name = "test-public-subnet"
}
    
  }
resource "aws_subnet" "test-private-subnet" {
  vpc_id = aws_vpc.test-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
  Name = "test-private-subnet"
  }
  
}
    

# Internet Gateway Configuration
  resource "aws_internet_gateway" "test_IGW" {
  vpc_id =  aws_vpc.test-vpc.id
  tags = {
  Name = "test_IGW"
  }
  }

# NAT Gateway Configuration
resource "aws_nat_gateway" "test_nat_gateway" {
  allocation_id = aws_eip.test_elastic_IP.id
  subnet_id     = aws_subnet.test-public-subnet.id
  tags = {
  Name = "test_nat_gateway"
  }
}

# Route Table Configuration
  resource "aws_route_table" "test_route_table" {
  vpc_id = aws_vpc.test-vpc.id
  route  {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.test_IGW.id
  }
  tags = {
  Name = "test_route_table"
   }
   }
  
# Route Table Association
resource "aws_route_table_association" "Public_RT_Association" {
  subnet_id      = aws_subnet.test-public-subnet.id
  route_table_id = aws_route_table.test_route_table.id
}

resource "aws_route_table" "test_Natgateway_route_table" {
  vpc_id = aws_vpc.test-vpc.id
  route  {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.test_nat_gateway.id    
  }
  tags = {
  Name = "test_Natgateway_route_table"
   }
   }
# Route Table Association
resource "aws_route_table_association" "private_RT_Association" {
  subnet_id      = aws_subnet.test-private-subnet.id
  route_table_id = aws_route_table.test_Natgateway_route_table.id
}

# Security Group Configuration
resource "aws_security_group" "test-sec-GRP" {
vpc_id = aws_vpc.test-vpc.id

    egress  {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
        
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    tags = {
      Name = "test_sec_GRP"
    }
}

# Key Pair Configuration
resource "aws_key_pair" "test-key" {
  key_name   = "test-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0nn/2Hy1ltf/NE3Igjr/bie6hn1KpzoHi+j6BC3YlrEr23ricNdhsaAUGOBNJO32nqWeSFM/uZMs5PHBXFwCaIaZdxPfNlFEXUmqcsvdzDhq1NefCF8dgdUgrORjhCoirGbZfoXXP3LJ7HZuTFiL8Ze8kS152WMtyLZGDXxUKU3M62TJt+MLQt7nVGmu81HD5wq6BsthyZPjbIJIRWj9vfetNZ9J2SSCZYIZwJDkM7xrxBo7ThYSZn5TVps1U5mkB8A3BsP9Xdgx+aawMADi7S2HfPP3bagdWES3TsYfhNRU00S2Y7tlEWPF41llYwvxEmwIxODn/t186+Lom7Ak7XVcvQzapXjqMPa4mwZUS70wBwr77A2S1WSUq1jGmEbLKvQ8oAQ8ZWGsd3yZOE9Ctca/McD7u9EJCx7BVkaCCwEBJW6AweM9xgGnRoefjfHegaja/y1qGnnz95pfwwI1AJu5dkg76Laurap0cM65PI1eYASalFe+a1R5648uMfx0= nay@nay"
}

 # EC2 Instance Elastic IP
  resource "aws_eip" "test_elastic_IP" {
  vpc = true
    
  }

# EC2 Instance Configuration
  resource "aws_instance" "test-publis-instance" {
  ami = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test-sec-GRP.id]
  subnet_id = aws_subnet.test-public-subnet.id
  key_name = "test-key"
  tags = {
  Name = "test-public-instance"

   }
  }

 

  # EC2 private Instance Configuration
  resource "aws_instance" "test-private-instance" {
  ami = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test-sec-GRP.id]
  subnet_id = aws_subnet.test-private-subnet.id
  key_name = "test-key"
  tags = {
  Name = "test-private-instance"

   }
  }
