#!/bin/bash

set -exuo pipefail

apt-get update -q
apt-get upgrade -y
apt-get install build-essential linux-headers-amd64 linux-image-amd64 python3-pip -y

adduser vagrant vboxsf
apt-get install task-xfce-desktop materia-gtk-theme papirus-icon-theme -y
systemctl set-default graphical.target
sed -i 's/Xfce/Materia-dark-compact/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
sed -i 's/Tango/Papirus-Dark/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
