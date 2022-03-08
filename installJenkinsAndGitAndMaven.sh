#!/bin/bash

apt-get update &&
apt-get install -y openjdk-11-jdk &&
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null &&
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null &&
apt-get update &&
apt-get install -y jenkins &&
apt-get install -y git &&
git --version &&
apt-get install -y maven &&
systemctl status jenkins &&
java -version &&
mvn --version