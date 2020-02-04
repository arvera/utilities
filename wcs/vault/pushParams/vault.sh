#!/bin/bash

set -eu
#set -x

# Check for arguments
if [ $# -lt  2 ]
  then
    echo "[ERROR] Insufficient arguments supplied"
    echo ""
    echo "Please provide two arguments: $0 <tenant_name> <target_env>"
fi

# The variables defined
TENANT=${1}
TARGET_ENV=${2}


comm_dir=$(cd "$(dirname "$0")"; pwd)

source $comm_dir/env.profile

# Get info from current kubernetes environment
vault_pod=$(kubectl  get po | grep vault.consul| awk '{print $1}')
pod_status=$(kubectl  get po | grep vault.consul| awk '{print $3}')
while [ $pod_status != "Running" ]
do pod_status=$(kubectl  get po | grep vault.consul| awk '{print $3}') && echo "waiting for vault_consul ready" && sleep 2s
done
sleep 10

myuname=$(uname)
if [[ "$myuname" == "Darwin" ]]; then
	vault_token=$(kubectl logs $vault_pod -c vault |grep "Root Token:" | awk  '{print $3}' | sed -E "s/"$'\E'"\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g")
elif [[ "$myuname" == "Linux" ]]; then
	vault_token=$(kubectl logs $vault_pod -c vault |grep "Root Token:" | awk  '{print $3}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g")
else
	echo "Untested client operating system. Assuming Linux, but results may not be as expected."
	vault_token=$(kubectl logs $vault_pod -c vault |grep "Root Token:" | awk  '{print $3}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g")
fi

kube_version=`kubectl version | grep Client | sed -E 's/.*(Minor:"([0-9][0-9]?).*)/\2/g'`

if [[ ${kube_version} -gt 7 ]];then
   echo "kube client version higher then 1.7"
   vault_port=$(kubectl get svc | grep vault-consul | awk '{print substr($5,6,5)}')
else
   echo "kube client version lower or equal then 1.7"
   vault_port=$(kubectl get svc | grep vault-consul | awk '{print substr($4,6,5)}')
fi

init_json='json_data={"type":"generic","description":"description","config":{"max_lease_ttl":"876000"}}'
header="X-Vault-Token:$vault_token"

# init vault and create mount point
echo "Creating mount point for ${TENANT}"
echo "$header"
echo "$kube_minion_ip:$vault_port"
sleep 1s
curl -X POST -H $header -H "Content-Type:application/json" -d '{"type":"generic","description":"description","config":{"max_lease_ttl":"876000"}}' http://$kube_minion_ip:$vault_port/v1/sys/mounts/${TENANT}


#pop
echo "push dbName to vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbNameAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbName
curl -X POST -H "$header" -d "{\"value\":\"$dbNameLive\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbName
sleep 1s

echo "push dbPassword to vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbPasswordAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbPassword
curl -X POST -H "$header" -d "{\"value\":\"$dbPasswordLive\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbPassword
sleep 1s


echo "push dbUser to vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbUserAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbUser
curl -X POST -H "$header" -d "{\"value\":\"$dbUserLive\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbUser
sleep 1s

#post dbHost into vault and consul
echo "push dbPort into vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbPortAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbPort
curl -X POST -H "$header" -d "{\"value\":\"$dbPortLive\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbPort
sleep 1s

echo "push dbHost into vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbHostAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbHost
curl -X POST -H "$header" -d "{\"value\":\"$dbHostLive\"}"  http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbHost
sleep 1s


#post domainName into vault and consul
echo "push domainName into vault" internalDomainName
curl -X POST -H "$header" -d "{\"value\":\"$internalDomainName\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/domainName


#post dbType into vault and consul (add this since 9.0.0.4 to support multiple db type)
#post domainName into vault and consul
echo "push dbtype into vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbType\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbType
curl -X POST -H "$header" -d "{\"value\":\"$dbType\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbType

echo "push dba encrypted password into vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbaPassEncryptAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbaPassEncrypt
curl -X POST -H "$header" -d "{\"value\":\"$dbaPassEncryptLive\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbaPassEncrypt

echo "push db encrypted password into vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbPassEncryptAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbPassEncrypt
curl -X POST -H "$header" -d "{\"value\":\"$dbPassEncryptLive\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbPassEncrypt

echo "push dba user into vault"
curl -X POST -H "$header" -d "{\"value\":\"$dbaUserAuth\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/auth/dbaUser
curl -X POST -H "$header" -d "{\"value\":\"$dbaUserLive\"}" http://$kube_minion_ip:$vault_port/v1/${TENANT}/${TARGET_ENV}/live/dbaUser

#Config PKI on vault and generate certs
echo "Create a Root Cert"
export VAULT_ADDR="http://$kube_minion_ip:$vault_port"
export VAULT_TOKEN=$vault_token
$comm_dir/vault mount -path=selfserve_production_pki -description="SelfServe Root CA" -max-lease-ttl=87600h pki
$comm_dir/vault write selfserve_production_pki/root/generate/internal common_name="selfserve_production_pki Root CA" ttl=87600h  key_bits=4096 exclude_cn_from_sans=true
$comm_dir/vault write  selfserve_production_pki/roles/generate-cert key_bits=2048  max_ttl=8760h allow_any_name=true

echo "Init Vault and Consul successfully"
echo -e "The Vault token is: " "\e[1;33m $vault_token \e[0m"
