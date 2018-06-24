#!/bin/bash

BUCKET_NAME="${bucket_name}"
REPL_BUCKET_NAME="${repl_bucket_name}"

cd /root

aws s3 cp "s3://$BUCKET_NAME/ossec/" confs/ --recursive

if [ $? -ne 0 ]; then
	aws s3 cp "s3://$REPL_BUCKET_NAME/ossec/" confs/ --recursive
fi

OSSEC_DIR="/var/ossec"

if ! [ -d "$OSSEC_DIR" ]; then
	mkdir -p "$OSSEC_DIR"
fi

tar xz -f confs/files/core.tar.gz -C "$OSSEC_DIR"

mv confs/backup_ossec.sh /usr/bin/

mv confs/user $OSSEC_DIR/api/configuration/auth/

chmod 700 /usr/bin/backup_ossec.sh

(crontab -l ; echo "0 */6 * * * /usr/bin/backup_ossec.sh") | crontab

# enable syslog in case the config file has the directive
syslog_on=`grep "syslog_output" $OSSEC_DIR/etc/ossec.conf`
if ! [ x"$syslog_on" = "x" ]; then
	$OSSEC_DIR/bin/ossec-control enable client-syslog
fi

/etc/init.d/wazuh-manager restart

/etc/init.d/wazuh-api restart

if [ -e confs/post-hooks-ossec ]; then
	echo "Running post-hooks..."
	bash confs/post-hooks-ossec
fi

rm -rf confs/