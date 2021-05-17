#!/bin/bash

if [[ "$#" -eq 0 ]]
then
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --aks-cluster-name) AKS_CLUSTER_NAME="$2"; shift ;;
        --aks-nodes-resource-group) AKS_NODES_RESOURCE_GROUP="$2"; shift ;;
        --dns-hostname) DNS_HOSTNAME="$2"; shift ;;
        --dns-resource-group) DNS_RESOURCE_GROUP="$2"; shift ;;
        --letsencrypt-contact-email) LETSENCRYPT_CONTACT="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Automatically determined variables
export AKS_CLUSTER_NAME=$AKS_CLUSTER_NAME
export AKS_NODES_RESOURCE_GROUP=$AKS_NODES_RESOURCE_GROUP
export DNS_HOSTNAME=$DNS_HOSTNAME
export DNS_RESOURCE_GROUP=$DNS_RESOURCE_GROUP
export LETSENCRYPT_CONTACT=$LETSENCRYPT_CONTACT
export DNS_MSI_CLIENTID=$(az ad sp list --display-name ${AKS_CLUSTER_NAME}-dns --query [].appId --output tsv)
export LETSENCRYPT_SECRET=star-${DNS_HOSTNAME//./-}
export AZURE_TENANT_ID=$(az account show --query tenantId --output tsv)
export AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_DIR="${REPO_ROOT}/clusters/${AKS_CLUSTER_NAME}/"

echo "*********************************************************"
echo -e "Azure Tenant id:\t\t${AZURE_TENANT_ID}"
echo -e "Azure Subscription id:\t\t${AZURE_SUBSCRIPTION_ID}"
echo
echo -e "AKS cluster name:\t\t${AKS_CLUSTER_NAME}"
echo -e "AKS nodes resource group:\t${AKS_NODES_RESOURCE_GROUP}"
echo
echo -e "DNS Resource Group:\t\t${DNS_RESOURCE_GROUP}"
echo -e "DNS Hostname:\t\t\t${DNS_HOSTNAME}"
echo -e "DNS MSI clientId:\t\t${DNS_MSI_CLIENTID}"
echo
echo -e "LetsEncrypt Contact:\t\t${LETSENCRYPT_CONTACT}"
echo -e "LetsEncrypt Secret:\t\t${LETSENCRYPT_SECRET}"
echo "*********************************************************"

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    pushd "${REPO_ROOT}/clusters/template/."
    for f in $(find . ! -path . -type d)
    do
        mkdir -p "${CLUSTER_DIR}${f//.}"
    done

    for f in $(find . -type f)
    do
        FILEPATH=$(echo $f | sed 's/.//')
        cat ${f} | envsubst > "${CLUSTER_DIR}${FILEPATH}"
    done
    popd
fi