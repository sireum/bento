#!/bin/sh -e
SCRIPT_DIR=$(cd -P $(dirname "$0") && pwd -P)
cd $SCRIPT_DIR/packer_templates/debian && packer build -only=virtualbox-iso debian-11.1-amd64-seL4.json
