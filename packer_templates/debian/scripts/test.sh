#!/bin/bash

set -exuo pipefail

: "${BASE_DIR:=$HOME/CASE}"

export LANG=en_US.UTF-8
export PATH=$PATH:$BASE_DIR/camkes/build/capDL-tool


cd "$BASE_DIR/sel4test"
mkdir build-x86_64
mkdir build-odroidxu4
cd build-x86_64
../init-build.sh -DPLATFORM=x86_64
ninja


cd "$BASE_DIR/camkes"
mkdir build
cd build
../init-build.sh
ninja
