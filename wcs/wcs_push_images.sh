#!/bin/bash

set -eu
#set -x

# Check for arguments
if [ $# -lt 2 ]
  then
    echo "[ERROR] Insufficient arguments supplied"
    echo ""
    echo "Please provide two arguments: $0 <tag> <target_private_registry_url>"
fi

# The variables defined
TAG=:${1}
target_private_registry_url=$2

docker tag commerce/ts-utils${TAG} ${target_private_registry_url}/commerce/ts-utils${TAG}
docker tag commerce/ts-web${TAG} ${target_private_registry_url}/commerce/ts-web${TAG}
docker tag commerce/ts-app${TAG} ${target_private_registry_url}/commerce/ts-app${TAG}
docker tag commerce/crs-app${TAG} ${target_private_registry_url}/commerce/crs-app${TAG}
docker tag commerce/search-app${TAG} ${target_private_registry_url}/commerce/search-app${TAG}

docker push ${target_private_registry_url}/commerce/ts-utils${TAG}
docker push ${target_private_registry_url}/commerce/ts-web${TAG}
docker push ${target_private_registry_url}/commerce/ts-app${TAG}
docker push ${target_private_registry_url}/commerce/crs-app${TAG}
docker push ${target_private_registry_url}/commerce/search-app${TAG}
