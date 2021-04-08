#!/bin/bash
yum update -y
amazon-linux-extras enable nginx1
yum clean metadata
yum install nginx -y
sudo bash -c 'echo ${nginx_file_content} > /usr/share/nginx/html/index.html'
service nginx start