#!/bin/bash

set -eu
#set -x

# Check for arguments
if [ $# -lt 2 ]
  then
    echo "[ERROR] Insufficient arguments supplied"
    echo ""
    echo "Please provide two arguments: $0 <vault_token> <master_node_ip>"
fi

# The variables defined
vault_token=$1
master_node_ip=$2

# The cmd to run
curl -X GET -H "X-Vault-Token:${vault_token}" http://${master_node_ip}:30552/v1/demo/qa/domainName"
