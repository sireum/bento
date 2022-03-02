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
# use agree 2.7.0 as 2.8.0 requires osate 2.10.x.  Fix others to their current 2022.03.02 versions
bin/install/fmide.cmd --agree agree_2.7.0 --briefcase briefcase_0.6.0 --hamr 1.2022.01051723.29d9922 --resolute resolute_2.7.2 fixed
bin/install/clion.cmd
#bin/install/compcert.cmd
rm -fR ~/Downloads/sireum

cat <<EOT >> $HOME/.bashrc

export SIREUM_HOME=${BASE_DIR}/Sireum
export PATH=\$SIREUM_HOME/bin:\$PATH
EOT
