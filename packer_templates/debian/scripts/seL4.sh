#!/bin/bash

set -exuo pipefail

: "${BASE_DIR:=$HOME/CASE}"

export LANG=en_US.UTF-8
export DESKTOP_MACHINE=no
export MAKE_CACHES=no
export DEBIAN_FRONTEND=noninteractive

SEL4_SCRIPTS=$BASE_DIR/seL4-CAmkES-L4v-dockerfiles/scripts

bash "$SEL4_SCRIPTS/base_tools.sh"

bash "$SEL4_SCRIPTS/sel4.sh"

. "$SEL4_SCRIPTS/utils/common.sh"

bash "$SEL4_SCRIPTS/camkes.sh"

bash "$SEL4_SCRIPTS/cakeml.sh"
