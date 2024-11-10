provider "aws" {
  region = "us-east-2"
  access_key = "AKIAY2ECJ2TMLMTXXN4W"
  secret_key = "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" #I have only granted read-only access.
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
