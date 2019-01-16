#!/bin/bash
sudo yum install httpd -y 
sudo echo Subnet for firewall: ${firewall_subnets} >> /var/www/html/index.html
sudo service httpd start
sudo chkconfig httpd on