#!/bin/bash

BUCKET_NAME="${bucket_name}"
REPL_BUCKET_NAME="${repl_bucket_name}"

temp_dir=`mktemp -d`
OSSEC_DIR="/var/ossec"

tar cz --directory="$OSSEC_DIR/" . -f "$temp_dir/core.tar.gz"

aws s3 cp $temp_dir/core.tar.gz "s3://$BUCKET_NAME/ossec/files/"

if [ $? -ne 0 ]; then
	aws s3 cp $temp_dir/core.tar.gz "s3://$REPL_BUCKET_NAME/ossec/files/"
fi

rm -rf $temp_dir
