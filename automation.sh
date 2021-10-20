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

File=/var/www/html/inventory.html

tar -cvf $name.tar /var/log/apache2/*.log

filename=$name.tar
#size={du -h $filename |awk '{print $1;}'}
#(du -h $filename) |awk '{print $1;}'

#Check whether inventory file exists. If exists, write records into it
if test -f "$File"; then
    echo "$File exists."

    echo "httpd-logs    $timestamp              ${filename: -3}         $(du -h                                                                                         $filename |awk '{print $1;}')
">>$File

#Creating new inventory file since it doesnt exist and writing records into it
else
	echo "inventory.html does not exists. Creating inventory.html"
	echo "************************************"
        echo "Log Type         Time Created         Type        Size" >$File
        echo "httpd-logs    $timestamp              ${filename: -3}         $(du                                                                                         -h $filename |awk '{print $1;}')
">>$File
fi


#Creating a crontab in /etc/cron.d/ directory
echo "************************************"
echo "Creating a crontab in /etc/cron.d/ directory"
echo "************************************"
echo "6 * * * * root /root/Automation_Project/automation.sh"> /etc/cron.d/automation

#Copying Log files to S3 bucket
echo "************************************"
echo "Copying Log files to S3 bucket"
echo "************************************"
bucketname="upgrad-aleena"
aws s3 \
cp /tmp/tardirt/$name.tar \
s3://$bucketname/$name.tar


