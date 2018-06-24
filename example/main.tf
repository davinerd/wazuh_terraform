provider "aws" {
  region = "${var.aws_region}"
}

provider "vault" {
  address = "${var.vault_addr}"
}

module "ossec" {
  source = "/path/to/module/ossec_wazuh"

  vpc_id = "vpc-e568d681"

  extra_tags = {
    project = "wazuh",
    squad = "Ops"
  }

  cluster_extra_tags = [
    {
      key = "Inspector"
      value = "wazuh-${var.wazuh_name}"
      propagate_at_launch = true
    },
    {
      key = "chaos_monkey"
      value = "true"
      propagate_at_launch = true
    }
  ]

  subnet_pub_ids = "subnet-99a104c1,subnet-e1a93c97"
  subnet_priv_ids = "subnet-e2a93c94,subnet-e6a104be"

  wazuh_name = "${var.wazuh_name}"

  wazuh_passwd = "${data.vault_generic_secret.wazuh_creds.data["password"]}"
  wazuh_username = "${data.vault_generic_secret.wazuh_creds.data["username"]}"

  s3_bucket_name = "${data.template_file.s3_bucket_name.rendered}"
  s3_replica_region = "${var.s3_replica_region}"

  upload_path = "${path.root}/upload/ossec"

  keypair_name = "${var.keypair_name}"

  ossec_ami_id = "${data.aws_ami.amzn_ossec_ami.image_id}"

  bastion_host_sg_id = "${aws_security_group.bastion_guac_elb_sg.id}"

  sns_topic = "arn:aws:sns:eu-west-1:XXXXXXXX:SlackNotify"

  route53_zone_id = "XXXXXXXXXXXXXX"
  dns_name = "${var.dns_record}"
}

module "cloudwatch_dashboard" {
  source = "/path/to/module/cloudwatch_ddos_dashboard"

  dashboard_name = "${var.wazuh_name}-ddos"

  lb_name = "${module.ossec.lb_zone_id}"
}

module "inspector" {
  source = "/path/to/module/inspector_automation"
  
  name = "${var.wazuh_name}"

  inspector_tag = "wazuh-${var.wazuh_name}"

  template_duration = 3600

  cloudwatch_sched_rule = "rate(7 days)"
}
