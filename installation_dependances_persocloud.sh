#!/bin/sh

COLOR='\033[1;3;38;5;208m'
NC='\033[0m'

# Update the package index files and Upgrade the system
sudo apt-get update
#sudo apt-get upgrade

echo "${COLOR}\nInstall dependents: Git, Node.js, VirtualBox, Vagrant, ssh${NC}"

# Install Git
echo "${COLOR}\nInstall Git\n${NC}"
sudo apt-get -y install git

# Install Node.js
echo "${COLOR}\nInstall Node.js\n${NC}"
sudo apt-get -y install nodejs nodejs-legacy npm

# Install VirtualBox
echo "${COLOR}\nInstall VirtualBox\n${NC}"
sudo apt-get -y install virtualbox

# Install Vagrant
echo "${COLOR}\nInstall Vagrant\n${NC}"
sudo apt-get -y install vagrant

# Install ssh
echo "${COLOR}\nInstall ssh\n${NC}"
sudo apt-get -y install openssh-client

# Update the package index files and Upgrade the system
echo "${COLOR}\nUpdate the package index files and Upgrade the system\n${NC}"
sudo apt-get update
#sudo apt-get upgrade
