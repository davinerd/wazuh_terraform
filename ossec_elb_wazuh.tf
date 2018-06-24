resource "aws_security_group" "wazuh_elb" {
  name        = "wazuh_elb-${var.wazuh_name}"
  description = "Wazuh traffic ELB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port    = 1514
    to_port      = 1514
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "wazuh_elb-${var.wazuh_name}"), var.extra_tags)}"
}

resource "aws_elb" "wazuh_elb" {
  name            = "wazuh-${var.wazuh_name}-elb"
  subnets         = ["${split(",", var.subnet_pub_ids)}"]
  security_groups = ["${aws_security_group.wazuh_elb.id}"]

  access_logs {
    bucket        = "${module.s3_elb_log.bucket_name}" # using 'module' instead of data.template_file to force dependency
    interval      = 5
  }

  listener {
    instance_port       = 55000
    instance_protocol   = "http"
    lb_port             = 443
    lb_protocol         = "https"
    ssl_certificate_id  = "${aws_acm_certificate_validation.cert.certificate_arn}"
  }

  listener {
    instance_port       = 1514
    instance_protocol   = "tcp"
    lb_port             = 1514
    lb_protocol         = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    target              = "TCP:55000"
    interval            = 30
  }

  connection_draining = true
  connection_draining_timeout = 300

  tags = "${merge(map("Name", "wazuh-${var.wazuh_name}-elb"), var.extra_tags)}"
}

resource "aws_lb_ssl_negotiation_policy" "wazuh_elb" {
  name = "${replace("wazuh-${var.wazuh_name}-ssl-policy", "_", "-")}"
  load_balancer = "${aws_elb.wazuh_elb.id}"
  lb_port = 443

  attribute {
    name = "Protocol-TLSv1.2"
    value = "true"
  }

  attribute {
    name = "Server-Defined-Cipher-Order"
    value = "true"
  }

  attribute {
    name = "ECDHE-ECDSA-AES256-GCM-SHA384"
    value = "true"
  }

  attribute {
    name = "ECDHE-RSA-AES256-GCM-SHA384"
    value = "true"
  }

  attribute {
    name = "ECDHE-ECDSA-AES128-GCM-SHA256"
    value = "true"
  }

  attribute {
    name = "ECDHE-ECDSA-AES256-SHA384"
    value = "true"
  }

  attribute {
    name = "ECDHE-RSA-AES256-SHA384"
    value = "true"
  }

  attribute {
    name = "ECDHE-ECDSA-AES128-SHA256"
    value = "true"
  }

  attribute {
    name = "ECDHE-RSA-AES128-SHA256"
    value = "true"
  }
}