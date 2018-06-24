output "wazuh_asg_name" {
	value = "${aws_autoscaling_group.ossec_wazuh_asg.name}"
}

output "lb_zone_id" {
  value = "${aws_elb.wazuh_elb.zone_id}"
}

output "lb_dns" {
  value = "${aws_elb.wazuh_elb.dns_name}"
}

output "lb_name" {
  value = "${aws_elb.wazuh_elb.name}"
}