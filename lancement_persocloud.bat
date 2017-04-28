@echo off
title Lancement de cozy-dev et de PersoCloud
rem %dossier% est le repertoire courant
set dossier=%~dp0
echo.
net session >nul 2>&1
if %errorLevel% == 0 (
	echo L'installeur ne doit pas etre execute en mode administrateur
	goto :end
)

if not "%dossier%"=="%dossier: =%" (
	echo Le chemin du repertoire courant ne doit pas contenir d'espace
	goto :end
)
IF NOT EXIST "%dossier%Vagrantfile.pc" (
	echo Le fichier '%dossier%Vagrantfile.pc' n'existe pas
	goto :end
)

echo Ce script peut etre utilise pour installer ou demarrer PersoCloud. 
echo.
echo Pour l'installation : Le script doit etre place dans le repertoire ou vous souhaitez installe l'application PersoCloud, l'API moteur et le Vagrantfile. Le fichier "Vagrantfile.pc" doit egalement etre dans ce dossier.
echo.
pause
echo Installation de cozy-dev et de PersoCloud
echo.
echo Verification des dependences...
where node
IF %ERRORLEVEL% NEQ 0 goto :errorNode
where npm
IF %ERRORLEVEL% NEQ 0 goto :errorNpm
where vagrant
IF %ERRORLEVEL% NEQ 0 goto :errorVagrant
where git
IF %ERRORLEVEL% NEQ 0 goto :errorGit 
where ssh
IF %ERRORLEVEL% NEQ 0 goto :errorSsh 
where /R "C:\Program Files\Oracle" VirtualBox.exe
IF %ERRORLEVEL% NEQ 0 goto :errorVirtualBox

IF EXIST "%dossier%PersoCloud" GOTO :persoCloudInstallMoteur
echo.
echo.
echo Telechargement et installation de l'application PersoCloud...
call git clone https://github.com/PersoCloud/PersoCloud.git
IF %ERRORLEVEL% NEQ 0 goto :error 
cd "%dossier%PersoCloud"
call npm install
IF %ERRORLEVEL% NEQ 0 goto :error 
cd "%dossier%"

:persoCloudInstallMoteur
IF EXIST "%dossier%API-Moteur" GOTO :cozyDevInstall
echo.
echo.
echo Telechargement et installation de l'API moteur...
call git clone https://github.com/PersoCloud/API-Moteur.git
IF %ERRORLEVEL% NEQ 0 goto :error 
cd "%dossier%API-Moteur"
call npm install
IF %ERRORLEVEL% NEQ 0 goto :error 
cd "%dossier%"

:cozyDevInstall
IF EXIST "%AppData%\npm\node_modules\cozy-dev" GOTO :cozyDevUpdate
echo.
echo.
echo Installation de cozy-dev...
call npm install -g cozy-dev 
IF %ERRORLEVEL% NEQ 0 goto :error

:cozyDevUpdate
echo.
echo Mise a jour de cozy-dev...
call npm update -g cozy-dev
IF %ERRORLEVEL% NEQ 0 goto :error

:cozyDevInit
cd %dossier%
IF EXIST "%dossier%Vagrantfile" GOTO :cozyDevStartQuestion
echo.
echo Initialisation de cozy-dev et creation du vagrantfile dans "%dossier%"
call cozy-dev vm:init
timeout /t 2

:cozyDevStartQuestion
copy "%dossier%Vagrantfile.pc" "%dossier%Vagrantfile"
IF %ERRORLEVEL% NEQ 0 goto :error
echo.
echo Demarrer la machine virtuelle ? [o/n]
set/p "cho=>"
if %cho%==o goto :cozyDevStart
if %cho%==n goto :cozyDevUpdateQuestion
goto cozyDevStartQuestion 

:cozyDevStart
echo.
echo.
echo Demarrage de la machine virtuelle...
echo.
call cozy-dev vm:start
IF %ERRORLEVEL% NEQ 0 goto :error

:cozyDevUpdateQuestion
echo.
echo Mettre a jour la machine virtuelle ? [o/n]
set/p "cho=>"
if %cho%==o goto :cozyDevVMUpdate
if %cho%==n goto :moteurInstallQuestion
goto cozyDevUpdateQuestion 

:cozyDevVMUpdate
echo.
echo.
echo Mise a jour de Cozy Cloud dans la machine virtuelle...
echo.
echo Attente de 30 secondes le temps que Cozy soit disponible...
timeout /t 30
call cozy-dev vm:update
IF %ERRORLEVEL% NEQ 0 goto :error

:moteurInstallQuestion
echo.
echo Demarrer le moteur PersoCloud ? [o/n]
set/p "cho=>"
if %cho%==o goto :moteurStart
if %cho%==n goto :cozyDevDeployQuestion
goto :moteurInstallQuestion

:moteurStart
start cmd.exe /k "title API Moteur - PersoCloud & echo Acces SSH a la VM... & echo. & echo Entrer 'cd /vagrant/API-Moteur' et 'npm start' pour lancer le moteur & echo Entrer 'cd /vagrant/API-Moteur/random_data_generator', 'npm install' si besoin et 'npm start' pour inserer des donnees dans le moteur. Modifier le fichier "random_data_generator.js" suivant les besoins. & echo. & echo ------------------------ & echo. & vagrant ssh"

:cozyDevDeployQuestion
echo.
echo Deployer l'application PersoCloud dans Cozy ? [o/n]
set/p "cho=>"
if %cho%==o goto :cozyDevDeploy
if %cho%==n goto :persoCloudStartQuestion
goto :cozyDevDeployQuestion

:cozyDevDeploy
echo.
echo.
echo Deploiement de PersoCloud dans CozyCloud...
echo.
cd %dossier%PersoCloud
echo Attente de 30 secondes le temps que Cozy soit disponible...
timeout /t 30
call cozy-dev deploy 9256
echo Si le deploiement a echoue, lancer un autre terminal et entrer "cozy-dev deploy 9256" dans PersoCloud/ d'ici quelques secondes
IF %ERRORLEVEL% NEQ 0 goto :error 
echo.

:persoCloudStartQuestion
echo.
echo Demarrer le serveur de l'application PersoCloud ? [o/n]
set/p "cho=>"
if %cho%==o goto :persoCloudStart
if %cho%==n goto :end
goto :persoCloudStartQuestion

:persoCloudStart
start cmd.exe /k "title API Serveur - PersoCloud & cd "%dossier%PersoCloud" & npm start"

:persoCloudClientStartQuestion
echo.
echo Lancer la compilation automatique de la partie cliente avec l'utilisation du moteur ? [o/n]
set/p "cho=>"
if %cho%==o goto :persoCloudClientStart
if %cho%==n goto :end
goto :persoCloudClientStartQuestion

:persoCloudClientStart
start cmd.exe /k "title Partie cliente - PersoCloud & cd "%dossier%PersoCloud/client" & npm run watch:dev_api"
goto :endD

:error
echo ERREUR : Une erreur est survenue
goto :end

:errorSsh
echo ERREUR : Pas de client SSH disponible. Il faut installer le client OpenSSH : https://www.mls-software.com/files/setupssh-7.4p1-1.exe
goto :end

:errorNode
echo ERREUR : Node n'est pas installe : https://nodejs.org/en/download/
goto :end

:errorNpm
echo ERREUR : npm n'est pas installe
goto :end

:errorVagrant
echo ERREUR : Vagrant n'est pas installe https://www.vagrantup.com/downloads.html
goto :end

:errorGit
echo ERREUR : Git n'est pas installe https://github.com/git-for-windows/git/releases/
goto :end

:errorVirtualBox
echo ERREUR : Virtual Box n'est pas installe https://www.virtualbox.org/wiki/Downloads
goto :end

:end
pause
:endD