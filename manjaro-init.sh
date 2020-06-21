#!/bin/sh

# manual steps
#echo 'turn off `tap to click` in touchpad settings'
#read xxx

# Enable "pamac AUR"
#sudo sed --in-place "s/#EnableAUR/EnableAUR/" "/etc/pamac.conf"

# Check for AUR Updates
#sudo sed --in-place "s/#CheckAURUpdates/CheckAURUpdates/" "/etc/pamac.conf"

#Enable "snap"
#sudo sed --in-place "s/#EnableSnap/EnableSnap/" "/etc/pamac.conf"

# show temperature in gnome upper panel
#xdg-open 'https://extensions.gnome.org/extension/841/freon/'
#echo 'click on toggle to install'
#read xxx

# installations

#pamac install google-chrome

#pamac install doublecmd-qt5

#pamac install spotify

#pamac install zoom-client

#snap install skype --classic

#snap install intellij-idea-ultimate --classic

#snap install slack --classic

# docker installation
#sudo pacman -Syu
#sudo pacman -S docker
#sudo systemctl start docker
#sudo systemctl enable docker
#sudo docker version
#sudo usermod -aG docker $USER
#pamac install docker-compose
#echo 'docker installed. now reboot computer'
#read xxx

# java
#pamac install jdk8-openjdk

# elm
#pamac install elm-bin
#pamac install elm-format-bin

#pamac install dbeaver


# java installation
# show possible versions
# sudo pacman -Ss openjdk 
# pamac install jdk8-openjdk

# google sdk and kubectl
pamac install google-cloud-sdk
pamac install kubectl

# install npm
pamac install npm

# It's generally discouraged to install extensions outside the home directory, the above one liner changes the global path from
# /usr
#  to
# /home/user/.node_modules_global
cd ~ && mkdir .node_modules_global && npm config set prefix=$HOME/.node_modules_global && npm config set prefix=$HOME/.node_modules_global

echo 'edit path in ~/.zshrc like export PATH="/home/fokot/.node_modules_global/bin:$PATH"   '

# TODO

# oh my zsh

# poweshell 10k

# windows fonts

