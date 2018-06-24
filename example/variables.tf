############## MANDATORY VARS #############
#
#
variable "wazuh_name" {
  type = "string"
  description = "Infrastructure's name"
}

variable "keypair_name" {
  type = "string"
  description = "Key Pair name to use"
}


############## VAULT STUFF ################
#
#
variable "vault_addr" {
  type = "string"
  description = "Vault address"
}

############### INFRASTRUCTURE ############
#
#
variable "aws_region" {
  type = "string"
  description = "AWS region"
}

variable "s3_replica_region" {
  type = "string"
  description = "S3 bucket replica region"
}

variable "dns_record" {
  type = "string"
  description = "DNS record to associate"
}