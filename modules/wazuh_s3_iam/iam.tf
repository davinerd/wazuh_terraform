########## ROLES ###########
#
#
resource "aws_iam_role" "ossec_wazuh_role" {
  name                = "ossec_wazuh-${var.main_bucket_name}-role"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "replica_role" {
  name               = "replica-${var.main_bucket_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


data "aws_iam_policy_document" "ossec_access_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    effect = "Allow"
        
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*",
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_repl_bucket.arn}/*",
      "${aws_s3_bucket.s3_repl_bucket.arn}"
    ]
  }

  statement {
    actions = [
      "s3:*"
    ]
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/ossec/files/*",
      "${aws_s3_bucket.s3_repl_bucket.arn}/ossec/files/*"
    ]
  }
}

data "aws_iam_policy_document" "replica_access_policy" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    effect = "Allow"
        
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}"
    ]
  }

  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    effect = "Allow"
        
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.s3_repl_bucket.arn}/*"
    ]
  }
}

############## POLICIES ####################
#
#
resource "aws_iam_policy" "ossec_policy" {
  name = "${var.main_bucket_name}-ossec_policy"
  policy =  "${data.aws_iam_policy_document.ossec_access_policy.json}"
}

resource "aws_iam_policy" "replica_policy" {
  name = "${var.main_bucket_name}-replication_policy"
  policy = "${data.aws_iam_policy_document.replica_access_policy.json}"
}

############## ATTACHMENTS ###################
#
#
resource "aws_iam_policy_attachment" "replica_attach" {
  name = "${var.main_bucket_name}-repl_policy_attachment"
  roles = ["${aws_iam_role.replica_role.name}"]
  policy_arn = "${aws_iam_policy.replica_policy.arn}"
}

resource "aws_iam_policy_attachment" "ossec_attach" {
  name = "${var.main_bucket_name}-ossec_policy_attachment"
  roles = ["${aws_iam_role.ossec_wazuh_role.name}"]
  policy_arn = "${aws_iam_policy.ossec_policy.arn}"
}

############# INSTANCE PROFILES ###################
#
#
resource "aws_iam_instance_profile" "ossec_wazuh_profile" {
  name = "ossec_wazuh-${var.main_bucket_name}-profile"
  role = "${aws_iam_role.ossec_wazuh_role.name}"

  # this sleep helps AWS to sync and get the profile ready to use
  # https://github.com/hashicorp/terraform/issues/2349
  provisioner "local-exec" {
    command = "sleep 10"
  }
}