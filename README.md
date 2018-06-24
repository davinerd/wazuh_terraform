# Wazuh-OSSEC
The following module spins up a [Wazuh-OSSEC](https://wazuh.com) environment. It creates:
* an Elastic Load Balancer (classic) alongside an S3 bucket for logging
* an AutoScaling Group
* two S3 buckets, one for the georeplica and the other for logs
* related IAM roles to make everything works
* associate a DNS to the ELB with an ACM certificate

It supports SSL/TLS termination on the ELB with TLS 1.2 with strong chipers.

For more details please take a look [here](http://docs.ips.cimpress.io/pages/171409433/File+Integrity+Monitor+Wazuh).

# Prerequisites
* working AWS credentials
* aws cli
* terraform
* htpasswd

# Input variables
- `wazuh_name` - Name to assign to the whole infrastructure.
- `wazuh_username` - Username to access Wazuh's API
- `wazuh_passwd` - Password to access Wazuh's API
- `upload_path` - Directory where to store files to be uploaded to S3
- `s3_bucket_name` - S3 bucket name
- `s3_replica_region` - S3 replica region
- `keypair_name` - Keypair name used to access EC2 instances
- `asg_number_of_instances` - Maximum number of instances in ASG (default to 1).
- `asg_minimum_number_of_instances` - Minimum number of instances in ASG (default to 1).
- `extra_tags` - A map of additional tags to add to ELBs and SGs. Each element in the map must have the key = value format.
- `cluster_extra_tags` - A list of additional tags to add to each Instance in the ASG. Each element in the list must be a map with the keys key, value, and propagate_at_launch.
- `ossec_ami_id` - AMI ID to use.
- `ossec_instance_type` - EC2 instance type (default t2.micro).
- `vpc_id` - VPC ID where to spin the infrastructure.
- `subnet_pub_ids` - Public subnet IDs where to spin the ELB.
- `subnet_priv_ids` - Private subnet IDs where to spin the EC2 instances.
- `bastion_host_sg_id` - Security Group ID of the bastion host (used to SSH into EC2 intances).
- `sns_topic` - SNS topic to use for ASG notifications.
- `dns_name` - The DNS name to associate with the ELB. It's the infrastructure's endpoint.
- `route53_zone_id` - Route53 Zone ID, used to create the DNS name.

# Output variables
- `wazuh_asg_name` - Name of the ASG.
- `lb_zone_id` - Load balancer ID.
- `lb_dns` - Load balancer DNS name.
- `lb_name` - Load balancer name

# Example
You can see a complete example usage in the `example` directory within this repository.

Here is a simple usage:
```
module "ossec" {
  source = "git::https://github.com/Cimpress-MCP/terraform.git//ossec_wazuh"

  vpc_id = "vpc-e568d381"

  extra_tags = {
    project = "wazuh",
    squad = "SET"
  }

  cluster_extra_tags = [
    {
      key = "chaos_monkey"
      value = "true"
      propagate_at_launch = true
    }, {
      key = "project"
      value = "wazuh3"
      propagate_at_launch = true
    }, {
      key = "squad"
      value = "SET"
      propagate_at_launch = true
    }
  ]

  subnet_pub_ids = "subnet-99a114c1,subnet-e1a43c97"
  subnet_priv_ids = "subnet-e2a93b94,subnet-e6a194be"

  wazuh_name = "wazuh"

  wazuh_username = "contemascetti"
  wazuh_passwd = "antani"
  
  s3_bucket_name = "fim-bucket"
  s3_replica_region = "us-west-1"

  upload_path = "${path.root}/upload/ossec"

  keypair_name = "fim_keypair"

  ossec_ami_id = "ami-123431"

  bastion_host_sg_id = "sg-12132121"

  sns_topic = "arn:aws:sns:eu-west-1:XXXXXXXX:SlackNotify"

  dns_name = "supercazzola.example.com"
  route53_zone_id = "ZC918BNT12XX"
}
```

# Packer AMI
In the directory `packer-ami` there is a script (`build.sh`) that calls packer to create a Wazuh AMI in your AWS account.

Simply run it with:
```
packer-ami/$ bash build.sh
```

It creates a CIS hardened (using the script found [here](https://github.com/nozaq/amazon-linux-cis)) AMI with an encrypted snapshot.