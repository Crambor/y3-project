#!/bin/bash

# please create a venv and pip install umbridge with the following command before running this script:
# python3 -m venv ./venv && source ./venv/bin/activate && pip install umbridge
SCRIPT_DIR="$(dirname $0)"

source $SCRIPT_DIR/venv/bin/activate
python3 $SCRIPT_DIR/servers/donut.py

