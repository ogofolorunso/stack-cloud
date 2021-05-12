#!/bin/bash

###Setting up EFS file on Instance
#sudo su -
sudo yum update -y
sudo yum install -y nfs-utils
sudo su - ec2-user
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo yum install git -y


##Get Code from Repo
#aws s3 cp s3://mystacks3website/index.html /var/www/html
#aws s3 cp s3://mystacks3website/Stack_IT_Logo.png /var/www/html


###INSTALL AND START LINUC APACHE MYSQL & PHP DRIVERS####
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cat /etc/system-release 
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
#sudo mysql_secure_installation
sudo yum install php-mbstring -y
sudo yum install php-xml -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm

####INSTALL PHPMYADMIN #####
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
#aws s3 cp s3://stackwpogo /var/www/html --recursive
git clone https://github.com/stackitgit/CliXX_Retail_Repository.git
cp -r CliXX_Retail_Repository/* /var/www/html


#####CONFIGURE CLIXX####
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
#cp -r wordpress/* /var/www/html/

###CREATE clixx DATABASE AND USER#
sudo sed -i 's/database_name_here/${DATABASE_NAME}/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/${DB_USERNAME}/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/${RDS_PASSWORD}/' /var/www/html/wp-config.php
sudo sed -i 's/localhost/${DB_HOST}/' /var/www/html/wp-config.php

## Allow wordpress to use Permalinks###
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf


sudo chkconfig httpd on
sudo systemctl status httpd

###CHANGE OWNERSHIP FOR APACHE AND RESTART SERVICES###
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd
sudo systemctl status httpd
sudo systemctl start httpd
curl http://169.254.169.254/latest/meta-data/public-ipv4


###UPDATE WORDPRESS URL TO LATEST INSTANCE IP ADDRESS###
mysql -h ${DB_HOST} -D ${DATABASE_NAME} -u\${DB_USERNAME} -p\${RDS_PASSWORD} <<EOT
use ${DATABASE_NAME};
UPDATE wp_options SET option_value = "http://${LB_DNS}" WHERE option_value LIKE 'http%';
commit;
EOT

