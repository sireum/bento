#!/bin/bash

set -exuo pipefail

: "${BASE_DIR:=$HOME/CASE}"
: "${GIT_USER:=Snail}"
: "${GIT_EMAIL:=<>}"
: "${SEL4_SCRIPTS_V:=e9079c69284bd79d817dd6e823d56821459083b9}"

apt-get update -q
apt-get upgrade -y
apt-get install repo ninja-build -y

mkdir -p "$BASE_DIR"

git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global color.ui true

cd "$BASE_DIR"
git clone https://github.com/SEL4PROJ/seL4-CAmkES-L4v-dockerfiles
SEL4_SCRIPTS=$BASE_DIR/seL4-CAmkES-L4v-dockerfiles/scripts
cd "$SEL4_SCRIPTS"
git checkout $SEL4_SCRIPTS_V

export LANG=en_US.UTF-8
export DESKTOP_MACHINE=no
export MAKE_CACHES=no
export DEBIAN_FRONTEND=noninteractive

SEL4_SCRIPTS=$BASE_DIR/seL4-CAmkES-L4v-dockerfiles/scripts

bash "$SEL4_SCRIPTS/base_tools.sh"

bash "$SEL4_SCRIPTS/sel4.sh"

. "$SEL4_SCRIPTS/utils/common.sh"

bash "$SEL4_SCRIPTS/camkes.sh"

possibly_toggle_apt_snapshot

bash "$SEL4_SCRIPTS/cakeml.sh"

echo 'en_US.UTF-8 UTF-8' | tee /etc/locale.gen > /dev/null
locale-gen
dpkg-reconfigure --frontend=noninteractive locales
echo "LANG=en_US.UTF-8" | tee -a /etc/default/locale > /dev/null

chown -fR vagrant "$BASE_DIR"
chgrp -fR vagrant "$BASE_DIR"

git config --global --unset user.name $GIT_USER
git config --global --unset user.email $GIT_EMAIL
