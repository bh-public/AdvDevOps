Artifactory install script for Cisco CloudCenter

General Information
-Service Type - Virtual Machine with Agent
-Service Logo - Put any jfrog logo you like

Name: jfrogArtifactory
Service ID: jfrogArtifactory
Description: JFrog Artifactory is the only Universal Repository Manager supporting all major packaging formats, build tools and CI servers.
Category: Select Custom Services
Supported Images
- Highlight CentOS 7.x
 
Default inbound firewall rules for VMs running this service
Rule
-Protocol: TCP
-From port: 8081
-To port: 8081
 
Agent Lifecycle Actions
-Configure
Select the repository where you have installed the script or use services/jfrog/jfrog_install.sh
Start
-service artifactory start
Stop
-service artifactory start

Note: from Bill, jfrog_install.sh is service also
