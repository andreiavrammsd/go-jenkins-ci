FROM jenkins/jenkins:lts

USER root
RUN apt update && apt install -y make gcc nano
USER jenkins

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Djenkins.CLI.disabled=true"

ADD JENKINS_HOME /usr/share/jenkins/ref

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
