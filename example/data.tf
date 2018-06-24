data "template_file" "s3_bucket_name" {
    template = "$${bucket_name}"

    vars {
      bucket_name = "wazuh-${var.wazuh_name}"
    }
}

data "aws_ami" "amzn_ossec_ami" {
  most_recent = true

  filter {
    name   = "tag-value"
    values = ["ossec"]
  }

  filter {
    name   = "tag-key"
    values = ["Service"]
  }
}

data "vault_generic_secret" "wazuh_creds" {
  path = "secret/wazuh_creds/test"
}