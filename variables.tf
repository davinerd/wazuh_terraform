variable "wazuh_name" {
  type = "string"
  description = "Infrastructure's name"
}

variable "wazuh_username" {
  type = "string"
  description = "Username to access Wazuh's APIs"
}

variable "wazuh_passwd" {
  type = "string"
  description = "Password to access Wazuh's APIs"
}

variable "upload_path" {
  type = "string"
  description = "Directory uploaded to S3"
}

variable "s3_bucket_name" {
  type = "string"
  description = "S3 bucket name"
}

variable "keypair_name" {
  type = "string"
  description = "Keypair name to access EC2 instance(s)"
}

############### ASG #####################
#
#
variable "asg_number_of_instances" {
  default = 1
}

variable "asg_minimum_number_of_instances" {
  default = 1
}

############ Tags ##############
#
#
variable "extra_tags" {
  type = "map"
  description = "A map of additional tags to add to ELBs and SGs. Each element in the map must have the key = value format"

  # example:
  # extra_tags = {
  #   "Environment" = "Dev",
  #   "Squad" = "Ops"
  # }

  default = {}
}

variable "cluster_extra_tags" {
  description = "A list of additional tags to add to each Instance in the ASG. Each element in the list must be a map with the keys key, value, and propagate_at_launch"
  type        = "list"

  #example:
  # default = [
  #   {
  #     key = "Environment"
  #     value = "Dev"
  #     propagate_at_launch = true
  #   } 
  # ]
  default = []
}

############# AMIs ###############
#
# 
variable "ossec_ami_id" {
  type = "string"
  description = "OSSEC AMI"
}

variable "ossec_instance_type" {
  type = "string"
  default = "t2.micro"
}

########### Infrastructure ############
#
#
variable "vpc_id" {
  type = "string"
  description = "Name of the VPC where to deploy the whole infrastructure"
}

variable "subnet_pub_ids" {
  type = "string"
  description = "Public subnet's ids (comma seperated)"
}

variable "subnet_priv_ids" {
  type = "string"
  description = "Private subnet's ids (comma seperated)"
}

variable "bastion_host_sg_id" {
  type = "string"
  description = "Bastion Host security group ID"
}

variable "sns_topic" {
  type = "string"
  description = "SNS ARN for notifications"
}

variable "s3_replica_region" {
  type = "string"
  description = "AWS region of the S3 replica"
}

variable "dns_name" {
  type = "string"
  description = "DNS name"
}

variable "route53_zone_id" {
  type = "string"
  description = "Route53 Zone ID"
}
