#!/bin/bash

yum update -y
yum install httpd -y
myinfo=`date`
echo "<h2> Server start time: $myinfo</h2><br>build by terraform" > /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
