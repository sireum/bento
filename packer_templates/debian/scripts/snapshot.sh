#!/bin/bash

set -exuo pipefail

: "${SNAPSHOT_DATE:=20211208T025308Z}"


tee /etc/apt/sources.list << EOF
deb http://snapshot.debian.org/archive/debian/$SNAPSHOT_DATE/ bullseye main contrib
deb http://snapshot.debian.org/archive/debian-security/$SNAPSHOT_DATE/ bullseye-security main contrib
deb http://snapshot.debian.org/archive/debian/$SNAPSHOT_DATE/ bullseye-updates main contrib
EOF

tee -a /etc/apt/apt.conf.d/80snapshot << EOF
Acquire::Retries "5";
Acquire::http::Dl-Limit "1000";
Acquire::Check-Valid-Until false;
EOF

echo "force-unsafe-io" | tee /etc/dpkg/dpkg.cfg.d/02apt-speedup > /dev/null
echo "Acquire::http {No-Cache=True;};" | tee /etc/apt/apt.conf.d/no-cache > /dev/null
