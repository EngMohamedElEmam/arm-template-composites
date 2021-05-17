# arm-template-composites
azure infrastructure arm templates 


to deploy the arm template from cloudshell

PS /home/mohamed> New-AzResourceGroupDeployment -Name d1 -ResourceGroupName aks-dev-elemam -mode Incremental -TemplateUri https://raw.githubusercontent.com/gkDigitalEcosystem/arm-template-composites/v0.0.6/templates/azuredeploy.json -TemplateParameterFile ./aks.json -verbose

# install aks cli 
PS /home/mohamed> az aks install-cli

#Add the AKS preview extension
PS /home/mohamed> az extension add --name aks-preview

# Get and store the credentials for the AKS cluster
PS /home/mohamed> az aks get-credentials --resource-group rg-prd-aks --name aks-prd-eastus-01 --overwrite-existing


# switch to bash then rum iam.sh 
mohamed@Azure:~$ sh iam.sh