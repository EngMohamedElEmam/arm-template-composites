AKS_DISPLAY_NAME="aks-dev-elemam-01"
AKS_AP_DISPLAY_NAME="${AKS_DISPLAY_NAME}-agentpool"
MSI_DNS_NAME="${AKS_DISPLAY_NAME}-dns"
AKS_RG="aks-dev-elemam"
AKS_NODES_RG="aks-dev-elemam-01-nodes"
DNS_ZONE="elemamm.developers.globalknowledge.io"
DNS_ZONE_RG="Azure-DNS"
VNET_RG="Network"
VNET_NAME="VN_EastUS"
SYS_SUBNET_NAME="SN-AKS-System"
NODE_SUBNET_NAME="SN-AKS-Workload"


SP_ID=$(az ad sp list --filter "displayName eq '${AKS_DISPLAY_NAME}'" --query [].appId --output tsv)
SP_AP_ID=$(az ad sp list --display-name ${AKS_AP_DISPLAY_NAME} --query [].appId --output tsv)

SP_MSI_DNS_ID=$(az ad sp list --display-name ${MSI_DNS_NAME} --query [].appId --output tsv)
DNS_ZONE_ID=$(az network dns zone show -g ${DNS_ZONE_RG} -n ${DNS_ZONE} --query id --output tsv)


az role assignment create --assignee $SP_AP_ID \
--role "Reader" \
--resource-group ${AKS_RG}

az role assignment create --assignee $SP_AP_ID \
--role "Contributor" \
--resource-group ${AKS_NODES_RG}

az role assignment create --assignee $SP_MSI_DNS_ID \
--role "Reader" \
--resource-group ${DNS_ZONE_RG}

az role assignment create --assignee $SP_MSI_DNS_ID \
--role "DNS Zone Contributor" \
--scope ${DNS_ZONE_ID}

# Grant the AKS Service Principal the Network Contributor role to the AKS node subnets.

SUBNET_ID=$(az network vnet subnet show -n $SYS_SUBNET_NAME -g $VNET_RG --vnet-name $VNET_NAME --query id --output tsv)
az role assignment create --assignee $SP_ID \
--role "Network Contributor" \
--scope ${SUBNET_ID}

SUBNET_ID=$(az network vnet subnet show -n $NODE_SUBNET_NAME -g $VNET_RG --vnet-name $VNET_NAME --query id --output tsv)
az role assignment create --assignee $SP_ID \
--role "Network Contributor" \
--scope ${SUBNET_ID}