data "template_file" "confs_path" {
  template = "$${path}"

  vars {
    path = "${path.module}/confs"
  }
}

data "template_file" "s3_repl_bucket_name" {
  template = "$${repl_bucket_name}"

  vars {
    repl_bucket_name = "${var.s3_bucket_name}-repl"
  }
}

data "template_file" "bucket_elb_log" {
  template = "$${bucketname}"

  vars {
    bucketname = "${var.s3_bucket_name}-elb-logs"
  }
}

############### CONF FILES ###############
#
#
data "template_file" "ossec_user_data" {
  template = "${file("${data.template_file.confs_path.rendered}/ossec_user_data.tpl")}"

  vars {
    bucket_name = "${var.s3_bucket_name}"
    repl_bucket_name = "${data.template_file.s3_repl_bucket_name.rendered}"
  }
}

data "template_file" "backup_ossec" {
  template = "${file("${data.template_file.confs_path.rendered}/backup_ossec.tpl")}"

  vars {
    bucket_name = "${var.s3_bucket_name}"
    repl_bucket_name = "${data.template_file.s3_repl_bucket_name.rendered}"
  }
}

############## SCRIPT FILES #############
#
#
data "template_file" "backup_ossec_file" {
  template = "$${filepath}"

  vars {
    filepath = "${var.upload_path}/backup_ossec.sh"
  }
}
