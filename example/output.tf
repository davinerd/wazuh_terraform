output "s3_bucket" {
  value = "${data.template_file.s3_bucket_name.rendered}"
}

output "wazuh_url" {
  value = "https://${var.dns_record}"
}

output "wazuh_lb" {
  value = "${module.ossec.lb_dns}"
}