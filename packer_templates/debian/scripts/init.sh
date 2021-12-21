#!/bin/bash

set -exuo pipefail

: "${BASE_DIR:=$HOME/CASE}"
: "${GIT_USER:=Snail}"
: "${GIT_EMAIL:=<>}"
: "${SEL4_SCRIPTS_V:=e9079c69284bd79d817dd6e823d56821459083b9}"
: "${SEL4_V:=e4bbc0fd0c5daf7f1529aaed5f0b07fc7a6d3fed}"
: "${CAMKES_V:=ae9f261fa3853e2243934209b8bf9bdf815cfa5d}"


mkdir -p "$BASE_DIR"

git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global color.ui true

cd "$BASE_DIR"
git clone https://github.com/SEL4PROJ/seL4-CAmkES-L4v-dockerfiles
SEL4_SCRIPTS=$BASE_DIR/seL4-CAmkES-L4v-dockerfiles/scripts
cd "$SEL4_SCRIPTS"
git checkout $SEL4_SCRIPTS_V

rm -fR ~/.sel4_cache "$BASE_DIR/sel4test"
mkdir -p ~/.sel4_cache
mkdir -p "$BASE_DIR/sel4test"
cd "$BASE_DIR/sel4test"
repo init -u "https://github.com/seL4/sel4test-manifest.git" --depth=1 -b $SEL4_V
repo sync -j 4

rm -fR "$BASE_DIR/camkes"
mkdir -p "$BASE_DIR/camkes"
cd "$BASE_DIR/camkes"
repo init -u "https://github.com/seL4/camkes-manifest.git" --depth=1 -b $CAMKES_V
repo sync -j 4

git config --global --unset user.name $GIT_USER
git config --global --unset user.email $GIT_EMAIL


echo "export LANG=en_US.UTF-8" >> "$HOME/.profile"
echo "export PATH=\$PATH:$BASE_DIR/camkes/build/capDL-tool" >> "$HOME/.profile"
