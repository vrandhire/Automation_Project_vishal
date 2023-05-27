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


inventory_file="/var/www/html/inventory.html"

# Check if inventory file exists, create it if not
if [[ ! -f "$inventory_file" ]]; then
    echo -e "Log Type\tDate Created\tType\tSize" > "$inventory_file"
fi


timestamp=$(date '+%d%m%Y-%H%M%S')

tar_file="/tmp/${myname}-httpd-logs-${timestamp}.tar.gz"
tar -czf "$tar_file" -C /var/log/apache2/ --exclude='*.zip' --exclude='*.tar' '*.log'

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar.gz s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar.gz

archive_size=$(du -h "$tar_file" | cut -f1)

log_type=$(basename "$tar_file" | cut -d'-' -f2)

echo -e "${log_type}\t${timestamp}\ttar\t${archive_size}" >> "$inventory_file"
