# Create a GitHub Repository with Multiple Branches
## Create Repository: Go to GitHub and create a new repository.
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/1.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/2.png)

## Install git in your local computer
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/3.png)
## Clone Repo: Clone it to your local machine.
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/4.png)

## Create Branches:  
Create develop and release branches and push them to the remote repository.
For pushing to the repository, you may be prompted for credentials. You can generate a personal access token or add an SSH key to your GitHub account for secure authentication.

# Create Terraform Code to Extract EC2 Instances and Security Groups
### Initialize Terraform Configuration: I used the official Terraform website to install Terraform and followed the instructions based on our operating system.[title](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/5.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/6.png)

I have created two files: one for launching the EC2 instance and the second for printing the EC2 and security group information.
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/7.png)

### CreateInstance/createInstance.tf This terraform file crate the ec2 instance.
  ![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/8.png)
  ![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/9.png)
  ![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/10.png)

     `provider "aws" {
	  region = "us-east-2" 
	}
	
	# Create a VPC
	resource "aws_vpc" "main" {
	  cidr_block = "10.0.0.0/16"
	  tags = {
	    Name = "main_vpc"
	  }
	}
	
	# Create subnets
	resource "aws_subnet" "subnet1" {
	  vpc_id = aws_vpc.main.id
	  cidr_block = "10.0.1.0/24"
	  availability_zone = "us-east-2a" 
	  map_public_ip_on_launch = true
	  tags = {
	    Name = "subnet1"
	  }
	}
	
	resource "aws_subnet" "subnet2" {
	  vpc_id = aws_vpc.main.id
	  cidr_block = "10.0.2.0/24"
	  availability_zone = "us-east-2b"
	  map_public_ip_on_launch = true
	  tags = {
	    Name = "subnet2"
	  }
	}
	
	# Create Internet Gateway
	resource "aws_internet_gateway" "gw" {
	  vpc_id = aws_vpc.main.id
	  tags = {
	    Name = "lucky-igw"
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
	    Name = "lucky-route-table"
	  }
	}
	# Associate route table with subnets
	resource "aws_route_table_association" "rta" {
	  count      = 2
	subnet_id = element([aws_subnet.subnet1.id, aws_subnet.subnet2.id], count.index)
	  route_table_id = aws_route_table.rt.id
	}
	# Create a security group
	resource "aws_security_group" "instance_sg" {
	  vpc_id = aws_vpc.main.id
	
	  ingress {
	    from_port = 22
	    to_port = 22
	    protocol = "tcp"
	    cidr_blocks = ["0.0.0.0/0"]
	  }
	
	  egress {
	    from_port = 0
	    to_port = 0
	    protocol = "-1"
	    cidr_blocks = ["0.0.0.0/0"]
	  }
	
	  tags = {
	    Name = "instance_sg"
	  }
	}
	
	# Create an EC2 instance
	resource "aws_instance" "FirstInstance" {
	  ami           = "ami-09caa684bdee947fc" 
	  instance_type = "t2.micro"
	  subnet_id     = aws_subnet.subnet1.id
	  vpc_security_group_ids = [aws_security_group.instance_sg.id]
	  tags = {
	    Name = "MyInstance"
	  }
	}`

For security reasons we haven't provide aws crdentials in the file. Due to that reason we have to configure the aws credential in our system.
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/11.png)

After creating the file, we need to initialize Terraform in that folder.
Command : `terraform init`
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/12.png)

Before applying the changes, we check if the code is working or not. 
Command : `terraform plan`
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/13.png)

If the plan is successful, then we can proceed with the apply.
Command: `terraform apply --auto-approve`
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/14.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/15.png)

This is the output in the AWS console showing that the Terraform file creates the instance. Finally, we launch the instances.

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/16.png)







