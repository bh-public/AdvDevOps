#!/bin/bash
exec > >(tee -a /var/tmp/jfrog-node-init_$$.log) 2>&1
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/agent_util.sh

#Declaring variable used in the script
PROXY_ADDRESS="http://proxy-wsa.esl.cisco.com:80"

#Script used for Jfrog Artifactory Server Service
# In case you have a local CloudCenter repository, disable it
sudo sed -i "s/enabled=1/enabled=0/" /etc/yum.repos.d/cliqr.repo 

# Checking if Java exist as it's a pre-requisite of tomcat
if [ -n `command -v java` ]; then
  agentSendLogMessage "Java check fails: installing JAVA..."
  sudo yum install java -y
else
  agentSendLogMessage "Artifactory pre-requisuite checks ok"
fi

sudo wget wget -e https_proxy=$PROXY_ADDRESS https://bintray.com/jfrog/artifactory-rpms/rpm -O bintray-jfrog-artifactory-rpms.repo
sudo mv bintray-jfrog-artifactory-rpms.repo /etc/yum.repos.d/

# Warning. We are going to install version 5.11. Latest versions works fine as well but we need to fix a Cross-Site Request Forgery for admin 
sudo sed -i "s/https/http/" /etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo
agentSendLogMessage "Installing jFrog Artifactory..."
sudo yum install jfrog-artifactory-oss-5.11.0 -y

sudo service artifactory start
agentSendLogMessage "Installed jFrog Artifactory"