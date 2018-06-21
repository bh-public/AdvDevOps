#!/bin/bash -x
exec > >(tee -a /var/tmp/jenkins-config_$$.log) 2>&1
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/cliqr.repo

#Declaring variable used in the script
#LOCAL_PROXY="http://proxy-wsa.esl.cisco.com:80"
#LOCAL_REPO="http://192.168.130.206"
C3_SSL_CERT_NAME="ccc.crt"


agentSendLogMessage "Installing JDK 8 ..."
# Installing JDK 8 as it's required for the application that will be built and eployed by Jenkins
# After all I've decided to install the Oralce JDK 8 171
cd /opt
#sudo wget -e use_proxy=yes -e https_proxy=$LOCAL_PROXY --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz"
sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz"

#Modified on the 24th of May by Stefano
sudo tar  xzf jdk-8u171-linux-x64.tar.gz

JDK_VER=`echo jdk-8u171-linux-x64.tar.gz | sed -r 's/jdk-([0-9]{1}u[0-9]{1,3}).*\.tar\.gz/\1/g'`
JDK_NAME=`echo $JDK_VER | sed -r 's/([0-9]{1})u([0-9]{1,2})/jdk1.\1.0_\2/g'`


mkdir /usr/local/java
touch /usr/bin/java /usr/bin/javac /usr/bin/javaws /usr/bin/jar
mv $JDK_NAME /usr/local/java
JAVA_HOME=/usr/local/java/$JDK_NAME

update-alternatives --install "/usr/bin/java" "java" "$JAVA_HOME/bin/java" 1
update-alternatives --set "java" "$JAVA_HOME/bin/java"
#End of the Modification

agentSendLogMessage "Java 1.8.0_171 installed in $JAVA_HOME/bin/java"

# Installing Maven 3.3.9
agentSendLogMessage "Installing Maven 3.3.9"
sudo wget http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
sudo tar xzf apache-maven-3.3.9-bin.tar.gz
sudo mkdir /usr/local/maven
sudo mv apache-maven-3.3.9/ /usr/local/maven/
# Adding Proxy to Maven
# sed -i "/<proxies>/a     <proxy>\n    <id>optional</id>\n    <protocol>http</protocol>\n     <host>proxy-wsa.esl.cisco.com</host>\n    <port>80</port>\n   </proxy>" /usr/local/maven/apache-maven-3.3.9/conf/settings.xml

#alternatives --install /usr/bin/mvn mvn /usr/local/maven/apache-maven-3.3.9/bin/mvn 1

# Import CloudCenter Certificates in the keystone
agentSendLogMessage "Configuring Jenkins"

# Step 1 - download config.xml
cd /var/lib/jenkins/
# sudo wget $LOCAL_REPO/services/jenkins/conf/config.xml
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/config.xml

# Step 2 - download Maven configuration fiesl
# sudo wget $LOCAL_REPO/services/jenkins/conf/hudson.tasks.Maven.xml
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/hudson.tasks.Maven.xml

###################### Step 3 - Create Jenkins project/jobs ######################
agentSendLogMessage "Creating jobs...."
cd /var/lib/jenkins/
sudo mkdir jobs
sudo mkdir jobs/$repoName
sudo mkdir jobs/deploy
cd jobs/$repoName
# sudo wget $LOCAL_REPO/services/jenkins/conf/project.zip
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/projec.zip
sudo unzip project.zip
# Bengin added on the 15th
cd /var/lib/jenkins/jobs/deploy
# sudo wget $LOCAL_REPO/services/jenkins/conf/job_deploy.zip
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/job_deploy.zip
sudo unzip job_deploy.zip
## Replace username and password used by the CloudCenter plugin
## <userName>jenkins_m</userName>
## <password>1FDBF7B2999D9EE3</password> 
## ccRestUserName and ccRestPassword

sudo sed -i "s/jenkins_m/$ccRestUserName/" /var/lib/jenkins/jobs/deploy/config.xml
sudo sed -i "s/1FDBF7B2999D9EE3/$ccRestPassword/" /var/lib/jenkins/jobs/deploy/config.xml
# End

###################### # Step 4 - download and install cloudcenter 4.8x plugin
agentSendLogMessage "Configuring CloudCenter jenkins plugin ..."
cd /var/lib/jenkins/plugins
# sudo wget $LOCAL_REPO/services/jenkins/conf/ccc_jenkin_plugin.zip
sudo wget /https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/ccc_jenkin_plugin.zip
sudo unzip ccc_jenkin_plugin.zip
sudo rm ccc_jenkin_plugin.zip
sudo mv cliqr.jenkins.plugin.CliQrJenkinsClient.CliQrJenkinsClientBuilder.xml /var/lib/jenkins/

######################  # Download and install modernstatus, to show red and green GUI button
cd /var/lib/jenkins/plugins
agentSendLogMessage "Configuring  modernstatus plugin ..."
# sudo wget $LOCAL_REPO/services/jenkins/conf/modernstatus.zip
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/modernstatus.zip
sudo unzip modernstatus.zip
sudo rm modernstatus.zip

######################  # Download and install parametized, to allow passing build number between jobs
cd /var/lib/jenkins/plugins
agentSendLogMessage "Configuring parameterized-trigger plugin ..."
# sudo wget $LOCAL_REPO/services/jenkins/conf/parameterized-trigger.hpi
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/parameterized-trigger.hpi

######################  # Download and install artifcatory plugin
cd /var/lib/jenkins/plugins
agentSendLogMessage "Configuring artifactory plugin ..."
# sudo wget $LOCAL_REPO/services/jenkins/conf/artifactory.hpi
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/artifactory.hpi
cd /var/lib/jenkins
# sudo wget $LOCAL_REPO/services/jenkins/conf/jenkins.model.ArtifactManagerConfiguration.xml
sudo wget /https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/jenkins.model.ArtifactManagerConfiguration.xml
# sudo wget $LOCAL_REPO/services/jenkins/conf/org.jfrog.hudson.ArtifactoryBuilder.xml
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/org.jfrog.hudson.ArtifactoryBuilder.xml

#Step 5 - download SSL certificate from CloudCenter
agentSendLogMessage "Configuring certifcates between Jenkins and CloudCenter..." 
cd /var/lib/jenkins/
# sudo wget $LOCAL_REPO/services/jenkins/$C3_SSL_CERT_NAME
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/$C3_SSL_CERT_NAME
#Adding to keystore. Note that if you changed the keystore default password you have to update the below command
sudo //usr/local/java/jdk1.8.0_171/bin/keytool -import -trustcacerts -alias cloudcenter -keystore /usr/local/java/jdk1.8.0_171/jre/lib/security/cacerts -file ccc.crt -noprompt -storepass changeit

# Step 6 - change all the password and IPS of the files
# start with svn password
agentSendLogMessage "Finalizing the configuration ...."

# Downloading subversion credentials
cd /var/lib/jenkins/jobs/$repoName
# sudo wget $LOCAL_REPO/services/jenkins/conf/subversion.credentials
sudo wget https://raw.githubusercontent.com/bh-public/AdvDevOps/master/CloudCenter/appz/jenkins/conf/subversion.credentials

sudo sed -i "s/SVN_UNAME/$repoAdmin/" /var/lib/jenkins/jobs/$repoName/subversion.credentials 
sudo sed -i "s/SVN_PWD/$repoPwd/" /var/lib/jenkins/jobs/$repoName/subversion.credentials 
sudo sed -i "s/SVN_ADDR/$CliqrTier_svn_PUBLIC_IP/" /var/lib/jenkins/jobs/$repoName/subversion.credentials  

sudo sed -i "s/REMOTE_SVN_URL/$CliqrTier_svn_PUBLIC_IP\/svn\/$repoName/" /var/lib/jenkins/jobs/$repoName/config.xml 
sudo sed -i "s/REPO_NAME/$repoName/" /var/lib/jenkins/jobs/$repoName/config.xml
sudo sed -i "s/REMOTE_ARTIFACTORY_URL/$CliqrTier_jfrog_PUBLIC_IP/" /var/lib/jenkins/jobs/$repoName/config.xml
sudo sed -i "s/ARTIFACTORY_REPOSITORY_KEY/$repoName/" /var/lib/jenkins/jobs/$repoName/config.xml

sudo sed -i "s/REMOTE_ARTIFACTORY_URL/$CliqrTier_jfrog_PUBLIC_IP/" /var/lib/jenkins/jenkins.model.ArtifactManagerConfiguration.xml
sudo sed -i "s/REMOTE_ARTIFACTORY_URL/$CliqrTier_jfrog_PUBLIC_IP/" /var/lib/jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml

#Step 6 -change ownership
cd /var/lib/jenkins
sudo chown -R jenkins:jenkins .

sudo systemctl restart jenkins
agentSendLogMessage "Job Done"
