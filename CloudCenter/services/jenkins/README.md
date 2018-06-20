Creating the Jenkins Service in Cisco CloudCenter
Follow the below instruction to create the Jenkins service (leave empty or default all the other entries).
 
General Information
-------------------
Service Type: Virtual Machine with Agent
Service Logo: Put any Jenkins logo you like
Name: Jenkins
Service ID: jenkins (make sure is all lower caps)
Description: Jenkins is an open source automation server written in Java. Jenkins helps to automate the non-human part of the software development process, with continuous integration and facilitating technical aspects of continuous delivery.
Category: Select Custom Services
Supported Images: Highlight CentOS 7.x
 
Default inbound firewall rules for VMs running this service
Rule Protocol: TCP
- From port: 443
- To port: 433
Rule:Protocol: TCP
- From port: 8080
- To port: 8080
 
Agent Lifecycle Actions
Configure: Select the repository where you have installed the script or use appz/jenkins/jenkins1.6-node-init.sh
Start
- service jenkins start
Stop
- service jenkins stop
Restart
- service jenkins restart

