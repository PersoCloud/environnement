@echo off
net session >nul 2>&1
if not %errorLevel% == 0 (
	echo L'installeur doit etre execute en mode administrateur
	goto :end
)
echo Bienvenue sur le script d'installation de PersoCloud et de ses dependances.
echo.
echo.
echo          :::::::::::::::::::::::::::::::::::::::::::::::::
echo          ::        INSTALLATION DES DEPENDANCES         ::
echo          :::::::::::::::::::::::::::::::::::::::::::::::::
echo.
echo.
echo ##################################################################
echo #           Chocolatey - https://chocolatey.org/install          #
echo ##################################################################
@echo off

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

echo L'installation de Chocolatey est terminee. Dependance (1/6) installee.

@echo off
echo.
echo ##################################################################
echo # OpenSSH - https://chocolatey.org/packages/mls-software-openssh #
echo ##################################################################
echo.
@echo off

choco install --force mls-software-openssh && choco upgrade mls-software-openssh

echo L'installation de OpenSSH for Windows est terminee. Dependance (2/6) installee.

@echo off
echo.
echo ##################################################################
echo #       Git - https://chocolatey.org/packages/git.install        #
echo ##################################################################
echo.
@echo off

choco install --force git && choco upgrade git

echo L'installation de Git est terminee. Dependance (3/6) installee.

@echo off
echo.
echo ##################################################################
echo #    Node.js - https://chocolatey.org/packages/nodejs.install    #
echo ##################################################################
echo.
@echo off

choco install --force nodejs.install && choco upgrade nodejs.install

echo L'installation de Node.js est terminee. Dependance (4/6) installee.

@echo off
echo.
echo ##################################################################
echo #    VirtualBox - https://chocolatey.org/packages/virtualbox     #
echo ##################################################################
echo.
@echo off

choco install --force virtualbox && choco upgrade virtualbox

echo L'installation de VirtualBox est terminee. Dependance (5/6) installee.

@echo off
echo.
echo ##################################################################
echo #       Vagrant - https://chocolatey.org/packages/vagrant        #
echo ##################################################################
echo.
@echo off

choco install --force vagrant && choco upgrade vagrant

echo L'installation de Vagrant est terminee. Dependance (6/6) installee.
echo.

@echo off
echo.
echo Le systeme a besoin d'etre redemarre pour finaliser l'installation des dependances.
set /p reponse=Voulez-vous redemarrer le systeme maintenant [O]ui/[N]on ? 
if "%reponse%"=="O" (shutdown /r /t 0) else exit
if "%reponse%"=="o" (shutdown /r /t 0) else exit
echo.

:end
pause