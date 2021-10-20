#!/bin/bash

#Updates the package information

echo "************************************"
echo "Updating the package information"
echo "************************************"

apt update -y

#Check whether Apache Server is installed or not

echo "Checking whether Apache Server is installed or not"

apachepres=$(apache2 -v)

if [[ $apachepres == *"Server version"* ]]; then
	echo "Apache Server is already installed"
else
	apt-get install apache2
fi

#Check whether Apache Server is running or not

echo "************************************"
echo "Checking whether Apache Server is running or not"
echo "************************************"

servstat=$(service apache2 status)
if [[ $servstat == *"active (running)"* ]]; then
  	echo "Apache Server is running"
else 
	echo "Apache Server is not running. Starting Apache Server..."
	service apache2 start|grep running
	echo "Apache Server Started"
	servstat=$(service apache2 status)
	if [[ $servstat == *"active (running)"* ]]; then
  	echo "Apache Server is running"
	fi	
fi

#Check whether Apache service is enabled or not

echo "************************************"
echo "Checking whether Apache service is enabled or not"
echo "************************************"

servenablestat=$(service apache2 status)
if [[ $servenablestat == *"/apache2.service; enabled"* ]]; then
	        echo "Apache Service is enabled"
else
	echo "Apache Service is disabled. Enabling Apache Service..."
        systemctl enable apache2|grep enabled
        echo "Apache Server Enabled"
fi

#Archiving Logs to S3

echo "************************************"
echo "Archiving Logs to S3"
echo "************************************"

cd /tmp/tardirt
timestamp=$(date '+%d%m%Y-%H%M%S')
name="aleena-httpd-logs-$timestamp"

tar -cvf $name.tar /var/log/apache2/*.log

bucketname="upgrad-aleena"
aws s3 \
cp /tmp/tardirt/$name.tar \
s3://$bucketname/$name.tar


