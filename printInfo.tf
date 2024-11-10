provider "aws" {
  region = "us-east-2"
}

variable "SecretKey" {
description = "This is for aws credential perpose"
type = string
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
}
