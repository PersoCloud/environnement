#!/bin/bash

INFO='\033[1;3;38;5;208m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pause () {
	read -n 1 -p "Appuyez sur une touche pour continuer..."
}

CheckDep () {
    if ! foobar_loc="$(type -p "$1")" || [ -z "$foobar_loc" ]; then
		echo -e "${RED}ERREUR : $1 n'est pas installé${NC}"
		pause
		exit
	else
		echo -e "${GREEN}$1 installé${NC}"
	fi
}

error () {
	echo -e "${RED}Une erreur s'est produite${NC}"
	pause
	exit
}

CheckError () {
    if [ ! $? -eq 0 ]; then	
		error 
	fi
}

ErrorVagrantfilePc () {
	echo -e "${RED}ERREUR : Le fichier 'Vagrantfile.pc' n'existe pas${NC}"
	pause
	exit
}

confirm() {
	read  -n 1 -r -p "$1 [o/n] : "
	printf "\n"
	if [[ $REPLY =~ ^[Oo]$ ]]; then 
		return 0
	elif [[ $REPLY =~ ^[Nn]$ ]]; then
		return 1
	else 
		confirm "$1"
	fi
}

if [  ! -f "Vagrantfile.pc" ]; then
	ErrorVagrantfilePc
fi
	
printf "Ce script peut etre utilisé pour installer ou démarrer PersoCloud.\n\n"
printf "Pour l'installation : Le script doit être placé dans le repertoire où vous souhaitez installé l'application PersoCloud et le Vagrantfile. Le fichier \"Vagrantfile.pc\" doit également être dans ce dossier.\n\n"
pause
printf "\nInstallation de cozy-dev et de PersoCloud\n"
printf "Verification des dependences...\n"
CheckDep node
CheckDep npm
CheckDep vagrant
CheckDep git
CheckDep ssh
case $OSTYPE in
  darwin*)
    CheckDep VirtualBox
    ;;
  *)
    CheckDep virtualbox
    ;;
  esac
printf "\n"

if [  ! -d "PersoCloud" ]; then 
	echo -e "${INFO}Téléchargement et installation de l'application PersoCloud...${NC}"
	git clone https://github.com/PersoCloud/PersoCloud.git
	CheckError
	cd "PersoCloud"
	npm install
	CheckError
	cd "../"
	printf "\n\n"
fi

if [  ! -d "API-Moteur" ]; then
	echo -e "${INFO}Téléchargement et installation de l'API moteur...${NC}"	
	git clone https://github.com/PersoCloud/API-Moteur.git
	CheckError
	cd "API-Moteur"
	npm install
	CheckError
	cd "../"
	printf "\n\n"
fi

if [  ! -d "/usr/local/lib/node_modules/cozy-dev" ]; then
	echo -e "${INFO}Installation de cozy-dev...${NC}"
	npm install -g cozy-dev 
	CheckError
fi

echo -e "${INFO}Mise à jour de cozy-dev...${NC}"
npm update -g cozy-dev
CheckError
printf "\n"

if [  ! -f "Vagrantfile" ]; then
	echo -e "${INFO}Initialisation de cozy-dev et création du Vagrantfile...${NC}"
	cozy-dev vm:init	
	timeout 2s sleep 4s	
	printf "\n"
fi

cp "Vagrantfile.pc" "Vagrantfile"
CheckError

if confirm "Demarrer la machine virtuelle ?"; then 
	printf "\n"
	echo -e "${INFO}Démarrage de la machine virtuelle...${NC}"
	cozy-dev vm:start
	CheckError
fi

printf "\n"

if confirm "Mettre à jour la machine virtuelle ?"; then 
	printf "\n"
	echo -e "${INFO}Mise a jour de Cozy Cloud dans la machine virtuelle...${NC}"
	echo -e "${INFO}Attente de 30 secondes le temps que Cozy soit disponible...${NC}"
	timeout 30s sleep 40s
	cozy-dev vm:update
	CheckError
fi

printf "\n"

if confirm "Démarrer le moteur PersoCloud ?"; then 
	gnome-terminal -e "bash -c 'printf \"\033]0;API Moteur - PersoCloud\007\"; echo -e \"${INFO}Acces SSH a la VM...\n\nEntrer \"cd /vagrant/API-Moteur\", \"npm install\" si besoin et \"npm start\" pour lancer le moteur.\nEntrer \"cd /vagrant/API-Moteur/random_data_generator\" et \"npm start\" pour insérer des données dans le moteur. Modifier le fichier \"random_data_generator.js\" suivant les besoins.${NC}\n\n\"; vagrant ssh; bash'"
fi

printf "\n"

if confirm "Déployer l'application PersoCloud dans Cozy ?"; then
	echo -e "${INFO}Déploiement de PersoCloud dans CozyCloud...${NC}"
	cd "PersoCloud"
	cozy-dev deploy 9256
	echo -e "${INFO}Si le deploiement à &chou&, lancer un autre terminal et entrer \"cozy-dev deploy 9256\" dans PersoCloud/ d'ici quelques secondes${NC}"
	CheckError
	cd "../"
fi

printf "\n"

if confirm "Démarrer le serveur de l'application PersoCloud ?"; then
	gnome-terminal -e "bash -c 'printf \"\033]0;API Serveur - PersoCloud\007\";cd \"PersoCloud\"; npm start; bash'"
fi

if confirm "Lancer la compilation automatique de la partie cliente avec l'utilisation du moteur ?"; then
	gnome-terminal -e "bash -c 'printf \"\033]0;Partie cliente - PersoCloud\007\";cd \"PersoCloud/client\"; npm run watch:dev_api; bash'"
fi
