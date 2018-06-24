# Wazuh S3 & IAM roles
This terraform module allows you to set up an S3 bucket + replica and logs to use within the Wazuh module at [link](link).

It also creates the necessary IAM roles to allow/restrict specific accesses to the buckets.

# Outputs

* *s3_bucket*: the S3 bucket name
* *ossec_wazuh_profile_name*: the Wazuh profile name (to use with the [wazuh module](link))

# Example

```
module "s3_repl_iam" {
  source = "/path/to/module/wazuh_s3_iam"

  main_bucket_name = "wazuh-main-bucket"

  replication_bucket_name = "wazuh-main-bucket-repl"

  replica_region = "eu-west-2"

  tag_name = "Wazuh Bucket"

  tag_project = "wazuh"

  tag_squad = "Ops"
}
```
