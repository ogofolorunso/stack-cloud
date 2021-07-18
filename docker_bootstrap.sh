#!/bin/bash

#Setting up Flask
sudo yum install pip -y
sudo pip install flask 
sudo yum install git -y
git clone --single-branch --branch Flaskapp https://github.com/ogofolorunso/stack-cloud.git
cd stack-cloud
mv Flaskapp /home/ec2-user/Flaskapp
cd ..
rm -rf stack-cloud
#python /home/ec2-user/Flaskapp/app.py


#Installing Docker 
sudo amazon-linux-extras install docker -y
sudo systemctl start docker.service
systemctl status docker.service
sudo usermod -a -G docker ec2-user
sudo docker info

#Dockerizing App
cd /home/ec2-user/Flaskapp
sudo docker build -f Dockerfile -t my-first-python-docker:latest .
sudo docker run -p 5001:5000 my-first-python-docker