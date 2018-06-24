resource "aws_security_group" "ossec_wazuh" {
  name        = "ossec_wazuh-${var.wazuh_name}"
  description = "ossec wazuh traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port    = 55000
    to_port      = 55000
    protocol     = "tcp"
    security_groups = ["${aws_security_group.wazuh_elb.id}"]
  }

  ingress {
    from_port    = 1514
    to_port      = 1514
    protocol     = "tcp"
    security_groups = ["${aws_security_group.wazuh_elb.id}"]
  }

  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    security_groups = ["${var.bastion_host_sg_id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "ossec_wazuh-${var.wazuh_name}"), var.extra_tags)}"
}

resource "aws_launch_configuration" "ossec_wazuh_launch_config" {
  name_prefix = "ossec_wazuh-${var.wazuh_name}-lc"
  image_id = "${var.ossec_ami_id}"
  instance_type = "${var.ossec_instance_type}"
  iam_instance_profile = "${module.s3_iam.ossec_wazuh_profile_name}"
  key_name = "${var.keypair_name}"
  security_groups = ["${aws_security_group.ossec_wazuh.id}"]
  user_data = "${data.template_file.ossec_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ossec_wazuh_asg" {
  depends_on = ["null_resource.upload_s3"]

  name = "ossec_wazuh-${var.wazuh_name}-asg"

  vpc_zone_identifier = ["${split(",", var.subnet_priv_ids)}"]

  launch_configuration = "${aws_launch_configuration.ossec_wazuh_launch_config.name}"

  max_size = "${var.asg_number_of_instances}"
  min_size = "${var.asg_minimum_number_of_instances}"
  desired_capacity = "${var.asg_number_of_instances}"

  health_check_type = "ELB"
  health_check_grace_period = 120

  load_balancers = ["${aws_elb.wazuh_elb.name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = ["${concat(
    list(
      map("key", "Name", "value", "ossec_wazuh-${var.wazuh_name}", "propagate_at_launch", true)
    ),
    var.cluster_extra_tags)
  }"]
}