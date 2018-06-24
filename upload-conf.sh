#!/bin/bash
## this script is intended to be executed via automation by Terraform
## it is not intended to be run interactively

function help() {
	echo "upload-conf.sh <bucket_name> <upload_path>"
	echo "- automated script to upload wazuh configuration to S3"
	echo "- recursively copies <upload_path> to the S3 bucket <bucket_name>"
}

# verify command line arguments have been passed in correctly
if [ -z "$1" ]; then
	echo "ERROR: missing <bucket_name> argument."
	echo ""
	help
	exit 1
fi

if [ -z "$2" ]; then
	echo "ERROR: missing <upload_path> argument."
	echo ""
	help
	exit 1
fi

BUCKETNAME="$1"
UPLOAD_PATH="$2"

aws s3api put-object --bucket $BUCKETNAME --key ossec/

if [ $? -ne 0 ]; then
	echo "[ERROR] Failed to create 'ossec' key in bucket $BUCKETNAME"
	exit 1
fi

if ! [ -d $UPLOAD_PATH ]; then
	echo "[ERROR] $UPLOAD_PATH does not exist or it's not a directory"
	exit 1
fi

aws s3 cp "$UPLOAD_PATH" "s3://$BUCKETNAME/ossec/" --recursive

if [ $? -ne 0 ]; then
	echo "[ERROR] Failed to upload files from $UPLOAD_PATH to $BUCKETNAME"
	exit 1
fi
