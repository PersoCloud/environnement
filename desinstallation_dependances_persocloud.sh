#!/bin/sh

COLOR='\033[1;3;38;5;208m'
NC='\033[0m'

gitUninstall() {
	echo "${COLOR}\nDesinstallation de Git\n${NC}"
  sudo apt remove --purge git
}

nodeUninstall() {
	echo "${COLOR}\nDesinstallation de Node.js\n${NC}"
  sudo apt remove --purge nodejs nodejs-legacy npm
  find / -name "*node_modules*" -exec rm -rf {} \;
}

virtualboxUninstall() {
	echo "${COLOR}\nDesinstallation de VirtualBox\n${NC}"
  sudo apt remove --purge virtualbox virtualbox-qt virtualbox-dkms
}

vagrantUninstall() {
	echo "${COLOR}\nDesinstallation de Vagrant\n${NC}"
  sudo apt remove --purge vagrant
  find / -name "*vagrant*" -exec rm -rf {} \;
}

sshUninstall() {
	echo "${COLOR}\nDesinstallation de ssh\n${NC}"
  sudo apt remove --purge openssh-client
}

allUninstall() {
	echo "${COLOR}\nDesinstallation des dependances de Cozy\n${NC}"

  gitUninstall

  nodeUninstall

  virtualboxUninstall

  vagrantUninstall

  sshUninstall

  sudo apt autoremove --purge

}

printhelp() {
  cat <<EOF
  Les commandes ci-dessous permettent la désinstallation progressive ou en même temps des dépendances :
  - Désinstallation de Git Client : git
  - Désinstallation de Node.js : node
  - Désinstallation de VirtualBox : virtualbox
  - Désinstallation de Vagrant : vagrant
  - Désinstallation de OpenSSH : ssh
  - Désinstallation de toutes les dépendances : all

  Pour installer ou mettre à jour le ou les logiciels, faites la saisie suivante :
  ./CozyDevUninstall.sh [commande]

EOF
}

[ -z "$1" ] && printhelp && exit

if [ -n "$1" ] ; then
    ${1}Uninstall
fi

sudo apt-get update
#sudo apt-get upgrade

exit 0
