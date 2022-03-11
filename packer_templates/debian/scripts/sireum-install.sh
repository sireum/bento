#!/bin/bash
set -ex
: "${BASE_DIR:=$HOME/CASE}"
: "${SIREUM_INIT_V:=latest}"
: "${SIREUM_V:=master}"

cd $BASE_DIR
rm -fR Sireum
git clone https://github.com/sireum/kekinian Sireum
cd Sireum
git checkout $SIREUM_V
git submodule update --init --recursive
bin/build.cmd setup
bin/install/ffmpeg-libs.cmd
bin/install/projector-server.cmd
bin/install/fmide.cmd
bin/install/clion.cmd
#bin/install/compcert.cmd
rm -fR ~/Downloads/sireum

cat <<EOT >> $HOME/.bashrc

export SIREUM_HOME=${BASE_DIR}/Sireum
export PATH=\$SIREUM_HOME/bin:\$PATH
EOT
