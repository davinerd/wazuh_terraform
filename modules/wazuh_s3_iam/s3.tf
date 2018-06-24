# this is the main (source) bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.main_bucket_name}"

  force_destroy = "${var.force_destroy}"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
  }

  lifecycle_rule {
    id = "rotate"
    enabled = true
    prefix = ""

    transition {
      days = "${var.transition_days}"
      storage_class = "${var.transition_storage_class}"
    }
  }

  replication_configuration {
    role = "${aws_iam_role.replica_role.arn}"
    rules {
      id = "repl_rule"
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.s3_repl_bucket.arn}"
        storage_class = "${var.replica_storage_class}"
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(map("Name", var.main_bucket_name), var.extra_tags)}"
}

resource "aws_s3_bucket" "s3_repl_bucket" {
  provider = "aws.repl"
  bucket   = "${var.replication_bucket_name}"

  force_destroy = "${var.force_destroy}"

  lifecycle_rule {
    id = "rotate"
    enabled = true
    prefix = ""

    transition {
      days = "${var.transition_days}"
      storage_class = "${var.transition_storage_class}"
    }
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(map("Name", "${var.main_bucket_name}-repl"), var.extra_tags)}"
}

# logging of the source bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.main_bucket_name}-logs"
  acl    = "log-delivery-write"

  force_destroy = "${var.force_destroy}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(map("Name", "${var.main_bucket_name}-logs"), var.extra_tags)}"
}