#!/bin/sh


#navigate to the /root/minisite3 directory and create a repo directory
#cd /root/minisite3
#mkdir uwverigames

#run mercurial to get this file first, or update the repo
#hg clone https://dada.cs.washington.edu/hgweb/verigames/ uwverigames
#or you could update:
#cd uwverigames
#hg pull -u https://dada.cs.washington.edu/hgweb/verigames/

#then run this script
#sh "uwverigames/PipeJam/website/install scripts/install.sh"

#install php
yum -y install php
#check to see if php-fpm installed, so might need to do
yum -y install php-fpm

#install mongo driver for python
yum -y install pymongo

#and start it? Doesn't hurt to do, even if it's already running
sudo /usr/sbin/php-fpm restart
#check to make sure port 9000 is being used (hopefully by php-fpm)
#  netstat -nap | grep LISTEN | grep 9000

#until we figure out why nginx doesn't like php, install Apache
sudo yum install httpd mod_ssl
#and start it
sudo /usr/sbin/apachectl start

#install java jdk
yum install java-1.7.0-openjdk-devel -y

#install dot
cp "uwverigames/website/install scripts/graphviz-rhel.repo" /etc/yum.repos.d/graphviz-rhel.repo
yum -y install 'graphviz*'

#compile java parts
cd uwverigames/website/html/java/
chmod 777 buildall.sh
./buildall.sh

#get verigames jar
wget verigames-dev.cs.washington.edu/demo/release/verigames.jar

#go back to the base dir 
cd ../../..
 
#copy upload stuff to apache website located on..
cp -r uwverigames/website/* /var/www/
mkdir /var/www/html/upload

#if we get nginx working with scripts, this would work:
#cp -r uwverigames/website/* /root/minisite3/public/upload

#set permissions
#read and write for the folders and parents (overkill?)
chmod 777 /var/www/html/scripts
chmod 777 /var/www/html/uploads
chmod 777 /var/www/html
chmod 777 /var/www
chmod 777 /var
#r,w,x for the scripts
chmod 777 /var/www/html/scripts/*.*

#run the proxy server
java -jar /root/minisite3/uwverigames/ProxyServer/ProxyServer.jar

#get the game, unzip it, and move it to the right directory
mkdir game
cd game
wget verigames-dev.cs.washington.edu/demo/release/PipeJamRelease.zip
unzip PipeJamRelease.zip
cp -r bin-release/* /root/minisite3/public/game

cd 
#get verigames jar
cd

#for this currently to work, scala needs to be copied over. Not currently in the download, as I don't know if it will be used long term
#find it on verigames-dev at htdocs/scala copy to /var/www/html/scala
#also, you don't probably want to spend the 15 hours reqired to upload the whole thing. Try the bin, lib, and meta(?) directories?
# and set permissions on this recursively...

#paths need to change in globals.php to find the typecheckers, currently should just be typecheckers/
#and in the typechecker files to find scala, at ../scala.
