#!/bin/bash
exec > >(tee -a /var/tmp/jfrog-node-init_$$.log) 2>&1
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/agent_util.sh


#Declaring variable used in the script
# Removing local repo, to point to bh-public github
#LOCAL_REPO="http://192.168.130.206"

# In case you have a local CloudCenter repository, disable it
sudo sed -i "s/enabled=1/enabled=0/" /etc/yum.repos.d/cliqr.repo 

# get the jfrog repository from the local repo as we have some issues with the Cisco proxy
cd /etc/yum.repos.d/
#sudo wget $LOCAL_REPO/appz/artifactory/jfrog.repo
# Modified for github
https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/artifactory/jfrog.repo
 
agentSendLogMessage "Installing jFrog Artifactory..."
sudo yum install jfrog-artifactory-oss -y

# Checking if Java exist as it's a pre-requisite of tomcat
if [ -n `command -v java` ]; then
  agentSendLogMessage "Java install check failed: we are now installing JAVA..."
  sudo yum install java -y
else
  agentSendLogMessage "Artifactory pre-requisuite checks ok"
fi


#Start jFrog Artifactory Service
sudo service artifactory start
agentSendLogMessage "Installed jFrog Artifactory"
