################ Create additional files #####################
#
resource "null_resource" "create_upload" {
    provisioner "local-exec" {
        command = "if ! [ -d  ${var.upload_path} ]; then mkdir -p ${var.upload_path} && mkdir ${var.upload_path}/files ; fi;"
    }
}

resource "null_resource" "generate_htpasswd" {
    depends_on = ["null_resource.create_upload"]

    # update config files
    provisioner "local-exec" {
        command = "htpasswd -b -c ${var.upload_path}/user ${var.wazuh_username} ${var.wazuh_passwd}"
    }
}

##################### Generate template file ######################
#
resource "null_resource" "dummy_backup_ossec" {
    depends_on = ["null_resource.create_upload"]

    # this will allow us to run this resource every time we run 'terraform apply'
    triggers = {
        dummy_var = "${data.template_file.backup_ossec.rendered}"
    }

    provisioner "local-exec" {
        command = "${format("cat <<\"EOF\" > \"%s\"\n%s\nEOF", data.template_file.backup_ossec_file.rendered, data.template_file.backup_ossec.rendered)}"
    }
}

################### Move core in upload ####################
#
resource "null_resource" "move_core" {
    depends_on = ["null_resource.create_upload"]

    # update config files
    provisioner "local-exec" {
        command = "cp ${data.template_file.confs_path.rendered}/core.tar.gz ${var.upload_path}/files/core.tar.gz"
    }
}

############# Upload stuff to S3 ###################
#
# We cannot use the s3_bucket_object since it doesn't support
# recursive folder upload. You need weird hacks to let all the files inside the folder
# to be uploaded. Best use this and wait for full support
resource "null_resource" "upload_s3" {
    depends_on = ["null_resource.dummy_backup_ossec", "null_resource.generate_htpasswd", "null_resource.move_core", "module.s3_iam"]

	# upload stuff to S3
	provisioner "local-exec" {
		command = "bash ${path.module}/upload-conf.sh ${var.s3_bucket_name} ${var.upload_path}"
	}
}

################# Revert conf changes #########################
#
resource "null_resource" "delete_htpasswd" {
    depends_on = ["null_resource.upload_s3"]
    provisioner "local-exec" {
        command = "rm -rf ${var.upload_path}/user"
    }
}

resource "null_resource" "delete_core" {
    depends_on = ["null_resource.upload_s3"]
    provisioner "local-exec" {
        command = "rm -rf ${var.upload_path}/files/core.tar.gz"
    }
}

resource "null_resource" "remove_scripts" {
    depends_on = ["null_resource.upload_s3"]
    provisioner "local-exec" {
        command = "rm -rf ${var.upload_path}/*.sh"
    }
}