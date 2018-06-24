output "s3_bucket" {
	value = "${aws_s3_bucket.s3_bucket.id}"
}

output "ossec_wazuh_profile_name" {
  value = "${aws_iam_instance_profile.ossec_wazuh_profile.name}"
}