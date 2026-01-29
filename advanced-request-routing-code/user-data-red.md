#!/bin/bash
yum update -y
yum install -y httpd
# start httpd daemon
systemctl start httpd
# set http daemon to run at boot time
systemctl enable httpd
mkdir /var/www/html/red
# populate /red directory of server with web page
cd /var/www/html/red
aws s3 cp s3://arr-bucket-test/hw-red.css ./
aws s3 cp s3://arr-bucket-test/hw-red-py.css ./
aws s3 cp s3://arr-bucket-test/python.png ./
aws s3 cp s3://arr-bucket-test/apache.svg ./
aws s3 cp s3://arr-bucket-test/red-index.html ./index.html
# populate root of web server with web page (replaces apache default page)
cd /var/www/html
aws s3 cp s3://arr-bucket-test/hw-red.css ./
aws s3 cp s3://arr-bucket-test/hw-red-py.css ./
aws s3 cp s3://arr-bucket-test/python.png ./
aws s3 cp s3://arr-bucket-test/apache.svg ./
aws s3 cp s3://arr-bucket-test/red-root-index.html ./index.html
# optional restart of httpd daemon
systemctl restart httpd


