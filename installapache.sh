#!/bin/bash

#Updating all packages and install Apache 
sudo yum update -y &&
sudo yum install -y httpd &&
sudo systemctl enable httpd
sudo systemctl start httpd
#Script for a customized apache webpage
cd /var/www/html
sudo echo "<html><body><h1>Welcome to my Apache webpage!</h1></body></html>" > /var/www/html/index.html
