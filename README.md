# Create a GitHub Repository with Multiple Branches

Create Repository: Go to GitHub and create a new repository.

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/1.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/2.png)

Install git in your local computer

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/3.png)

Clone Repo: Clone it to your local machine.

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/4.png)

### Create Branches:  
Create develop and release branches and push them to the remote repository.
For pushing to the repository, you may be prompted for credentials. You can generate a personal access token or add an SSH key to your GitHub account for secure authentication.

# Create Terraform Code to Extract EC2 Instances and Security Groups
Initialize Terraform Configuration: I used the official Terraform website to install Terraform and followed the instructions based on our operating system. [Link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/5.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/6.png)

I have created two files: one for launching the EC2 instance and the second for printing the EC2 and security group information.

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/7.png)

This terraform file crate the ec2 instance.
**CreateInstance/createInstance.tf**: 

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
    Environment = "Test"
    Project = "DevOpsProject"
    Owner = "Lakshman"
    Purpose = "Data_Extraction"
    Region = "Ohio"
    Avilability_zone = "us-east-2a"
    LifyCycly = "Temperory"
    ManagedBy = "Terraform"
    DateCreated = "11/11/2024"
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
    Environment = "Test"
    Project = "DevOpsProject"
    Owner = "Lakshman"
    Purpose = "Data_Extraction"
    Region = "Ohio"
    Avilability_zone = "us-east-2a"
    Service = "ec2"
    LifyCycle = "Temperory"
    ManagedBy = "Terraform"
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

### This file will extract the information of EC2 and security groups: 
**printInfo.tf**  

	`provider "aws" {
	  region = "us-east-2" # Replace with your region
	}
	
	# Data source to retrieve all EC2 instances
	data "aws_instances" "all" {}
	
	# Loop through each instance to get detailed information
	data "aws_instance" "details" {
	  for_each = toset(data.aws_instances.all.ids)
	  instance_id = each.value
	}
	# Output block to print instance IDs
	output "ec2_instance_ids" {
	value = data.aws_instances.all.ids
	}
	
	# Output block to print instance IDs and associated security groups
	output "ec2_instances_and_security_groups" {
	  value = {
	    for id, instance in data.aws_instance.details:
	    id => instance.vpc_security_group_ids
	  }
	}`

 
This file follows the same process: 
```
terraform init
terraform plan
terraform apply --auto-approve.
```
 ![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/18.png)

 For destroy the infra
Command: `terraform destroy --auto-approve`

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/19.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/20.png)

Now we push these files into github repository

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/21.png)

# Set Up a Jenkins Pipeline

### Downloading and installing Jenkins
Completing the previous steps enables you to download and install Jenkins on AWS. To download and install Jenkins:  [Jenkins Install](https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/)

1. Ensure that your software packages are up to date on your instance by using the following command to perform a quick software update:
$ sudo yum update –y
2. Add the Jenkins repo using the following command:
$ sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
3. Import a key file from Jenkins-CI to enable installation from the package:
$ sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
$ sudo yum upgrade
4. Install Java (Amazon Linux 2023):
$ sudo dnf install java-17-amazon-corretto -y
5. Install Jenkins:
$ sudo yum install jenkins -y
6. Enable the Jenkins service to start at boot:
$ sudo systemctl enable jenkins
7. Start Jenkins as a service:
$ sudo systemctl start jenkins
You can check the status of the Jenkins service using the command:
$ sudo systemctl status jenkins

### Create a Pipeline Job in Jenkins:
Open Jenkins and create a new Pipeline job.
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/22.png)

### Add Pipeline Script:
This is pipeline not use the webhooks. We can see the pipeline only build when we do manually.
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/23.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/24.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/25.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/26.png)

**We have now set up build triggers using GitHub webhooks. Whenever changes are made to the code and pushed to the master branch, the pipeline will automatically trigger and complete the build.**

![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/27.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/28.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/29.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/30.png)
![image](https://github.com/LakshmanBolisetti/TCSDevOps/blob/master/Resources/31.png)








