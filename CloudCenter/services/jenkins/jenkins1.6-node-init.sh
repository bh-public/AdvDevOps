#!/bin/bash -x
exec > >(tee -a /var/tmp/jenkins1.6-node-init-_$$.log) 2>&1
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

#Declaring variable used in the script
# LOCAL_REPOSITORY=http://192.168.130.206
# not using LOCAL, but public github

#Script used for Jenkins Service
# In case you have a local CloudCenter repository, disable it
sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/cliqr.repo

agentSendLogMessage "Updating system ..."
sudo yum update all -y
sudo yum remove java -y

agentSendLogMessage "Installing prerequisites ..."
sudo yum install java-1.7.0 -y

agentSendLogMessage "Downloading & Installing Jenkins ..."
#wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
# Downloading a specific supported version of Jenkins for CloudCenter 4.8.x
#sudo wget $LOCAL_REPOSITORY/appz/jenkins/jenkins-1.624-1.1.noarch.rpm
sudo wget https://raw.githubusercontent.com/bh-public/Jenkins/master/jenkins-1.624-1.1.noarch.rpm
sudo rpm -ivh jenkins-1.624-1.1.noarch.rpm

agentSendLogMessage "Starting Jenkins ..."
sudo systemctl start jenkins.service
sudo systemctl status jenkins.service
sudo systemctl enable jenkins.service

agentSendLogMessage "Jenkins installed"
