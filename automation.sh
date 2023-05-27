#!/bin/bash

myname="vishal"
s3_bucket="upgrad-vishal"

sudo apt update -y

if ! dpkg -s apache2 >/dev/null 2>&1; then
    sudo apt install apache2 -y
fi

if ! systemctl is-active --quiet apache2; then
    sudo systemctl start apache2
fi

if ! systemctl is-enabled --quiet apache2; then
    sudo systemctl enable apache2
fi


timestamp=$(date '+%d%m%Y-%H%M%S')
tar -cf /tmp/${myname}-httpd-logs-${timestamp}.tar.gz -C /var/log/apache2/ '*.log'


aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar.gz s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar.gz
