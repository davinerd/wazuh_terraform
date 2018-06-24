module "s3_elb_log" {
  source = "git::https://github.com/Cimpress-MCP/terraform.git//s3_elb_access_logs?ref=v0.1.1"

  bucket_name = "${data.template_file.bucket_elb_log.rendered}"
}

module "s3_iam" {
  source = "modules/wazuh_s3_iam"

  main_bucket_name = "${var.s3_bucket_name}"

  replication_bucket_name = "${data.template_file.s3_repl_bucket_name.rendered}"

  replica_region = "${var.s3_replica_region}"
}

module "asg_sns_notifications" {
  source = "git::https://github.com/Cimpress-MCP/terraform.git//asg_sns_notifications?ref=v0.1.1"

  asg_names = "${aws_autoscaling_group.ossec_wazuh_asg.name}"

  sns_topic = "${var.sns_topic}"
}

resource "aws_route53_record" "www" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.dns_name}"
  type    = "A"

  alias {
    name    = "${aws_elb.wazuh_elb.dns_name}"
    zone_id = "${aws_elb.wazuh_elb.zone_id}"
    evaluate_target_health = false
  }
}