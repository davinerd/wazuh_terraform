variable "main_bucket_name" {
  type = "string"
  description = "Bucket's name"
}

variable "force_destroy" {
  description = "Specify if the S3 bucket can be destroy even if data resides inside it (valid for the main, the replica and the logs buckets)"
  default = true
}

################## REPLICA ###############
#
#
provider "aws" {
  alias  = "repl"
  region = "${var.replica_region}"
}

variable "replica_region" {
  type = "string"
  description = "AWS region of the S3 replica"
}

variable "replication_bucket_name" {
  type = "string"
  description = "Bucket name used for replication"
}

variable "replica_storage_class" {
  type = "string"
  description = "Storage class for S3 bucket replica"
  default = "STANDARD"
}

variable "transition_storage_class" {
  type = "string"
  description = "Storage class for S3 bucket transition"
  default = "STANDARD_IA"
}

variable "transition_days" {
  type = "string"
  description = "Days to start the transition (valid for both the main and the replica buckets)"
  default = "60"
}

############## TAGS #################
#
#
variable "extra_tags" {
  type = "map"
  description = "A map of additional tags to add to the S3 buckets. Each element in the map must have the key = value format"

  # example:
  # extra_tags = {
  #   "Environment" = "Dev",
  #   "Squad" = "Ops"  
  # }

  default = {}
}