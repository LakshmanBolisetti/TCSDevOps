provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "main_vpc"
    Environment = "Development"
    Owner       = "Lakshman"
    Project     = "NetworkSetup"
    ManagedBy   = "Terraform"
    Region      = "us-east-2"
    Purpose     = "Network_Management"
    CostCenter  = "12345"
  }
}

# Create subnets
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "subnet1"
    Environment = "Development"
    Owner       = "Lakshman"
    Project     = "NetworkSetup"
    ManagedBy   = "Terraform"
    Region      = "us-east-2"
    Purpose     = "Subnet_Management"
    CostCenter  = "12345"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name        = "subnet2"
    Environment = "Development"
    Owner       = "Lakshman"
    Project     = "NetworkSetup"
    ManagedBy   = "Terraform"
    Region      = "us-east-2"
    Purpose     = "Subnet_Management"
    CostCenter  = "12345"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "lucky-igw"
    Environment = "Development"
    Owner       = "Lakshman"
    Project     = "NetworkSetup"
    ManagedBy   = "Terraform"
    Region      = "us-east-2"
    Purpose     = "Internet_Gateway"
    CostCenter  = "12345"
  }
}

# Create route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "lucky-route-table"
    Environment = "Development"
    Owner       = "Lakshman"
    Project     = "NetworkSetup"
    ManagedBy   = "Terraform"
    Region      = "us-east-2"
    Purpose     = "Route_Table"
    CostCenter  = "12345"
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "rta" {
  count           = 2
  subnet_id       = element([aws_subnet.subnet1.id, aws_subnet.subnet2.id], count.index)
  route_table_id  = aws_route_table.rt.id
}

# Create a security group
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name             = "instance_sg"
    Environment      = "Test"
    Project          = "DevOpsProject"
    Owner            = "Lakshman"
    Purpose          = "Data_Extraction"
    Region           = "Ohio"
    CostCenter       = "12345"
    Lifecycle        = "Temporary"
    ManagedBy        = "Terraform"
    DateCreated      = "11/11/2024"
  }
}

# Create an EC2 instance
resource "aws_instance" "FirstInstance" {
  ami                   = "ami-09caa684bdee947fc"
  instance_type         = "t2.micro"
  subnet_id             = element([aws_subnet.subnet1.id, aws_subnet.subnet2.id], count.index%2)
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  tags = {
    Name             = "MyInstance-${count.index + 1}"
    Environment      = "Test"
    Project          = "DevOpsProject"
    Owner            = "Lakshman"
    Purpose          = "Data_Extraction"
    Region           = "Ohio"
    AvailabilityZone = "us-east"
    Service          = "ec2"
    Lifecycle        = "Temporary"
    ManagedBy        = "Terraform"
  }
    count = 5
}
