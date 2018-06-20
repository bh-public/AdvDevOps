#!/bin/bash
exec > >(tee -a /var/tmp/jfrog-configure_$$.log) 2>&1
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/agent_util.sh


# Deactivate local repository in case you have one
#sudo sed -i "s/enabled=1/enabled=0/" /etc/yum.repos.d/cliqr.repo 

agentSendLogMessage "Configuring jFrog Artifactory"
sleep 20

# Now we will have to create the repository wirth the name specified at deployment time.
# Sadly, Jfrog OSS edition DOES NOT LLOW YOU to use any CLI/REST API, so to comnfigure it
# we have to make curl request to simulate the an admin using the GUI

# @repoName The name of the repository specified in the Global parameter of AdvancedDevOps

curl "http://127.0.0.1:8081/artifactory/ui/auth/login?_spring_security_remember_me=false"\
 -H "Accept-Encoding: gzip, deflate"\
 -H "Content-Type: application/json"\
 -H "Accept-Language: en,it-IT;q=0.9,it;q=0.8,en-US;q=0.7"\
 -H "Accept: application/json, text/plain, */*" -H "Connection: keep-alive"\
 -H "Request-Agent: artifactoryUI"\
 --data-binary "{\"user\":\"admin\",\"password\":\"password\",\"type\":\"login\"}"\
 --compressed -c cookie.txt 


curl "http://127.0.0.1:8081/artifactory/ui/admin/repositories"\
 -H "Accept-Encoding: gzip, deflate"\
 -H "Content-Type: application/json"\
 -H "Accept-Language: en,it-IT;q=0.9,it;q=0.8,en-US;q=0.7"\
 -H "Accept: application/json, text/plain, */*"\
 -H "Connection: keep-alive"\
 -H "Request-Agent: artifactoryUI"\
 --data-binary @<(cat <<EOF
{"type":"localRepoConfig","typeSpecific":{"localChecksumPolicy":"CLIENT","repoType":"Generic","icon":"generic","text":"Generic","listRemoteFolderItems":true,"url":""},"advanced":{"cache":{"keepUnusedArtifactsHours":"","retrievalCachePeriodSecs":600,"assumedOfflineLimitSecs":300,"missedRetrievalCachePeriodSecs":1800},"network":{"socketTimeout":15000,"syncProperties":false,"lenientHostAuth":false,"cookieManagement":false},"blackedOut":false,"allowContentBrowsing":false},"basic":{"includesPattern":"**/*","includesPatternArray":["**/*"],"excludesPatternArray":[],"layout":"simple-default"},"general":{"repoKey":"$repoName"}}
EOF
) -b cookie.txt

agentSendLogMessage "Configuration completed. Repository created"
