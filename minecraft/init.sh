#!/bin/bash

####################################
### PLEASE CHANGE THIS VARIABLES ###
####################################
LOCATION='japaneast'                # azure deploy region
RGNAME='minecraft-aci-container-rg' # resource group name
STNAME='ktkrbest001'                # storage account name (unique scope is global)
DNSNAME='ktkrminecraft001'          # DNS name (unique scope is global))
####################################

COMPOSEPROJECT='aci-minecraft' # ACI resource name
STSHARENAME='minecraft-data'

cat <<EOF >./.env
STNAME=${STNAME}
STSHARENAME=${STSHARENAME}
COMPOSE_PROJECT_NAME=${COMPOSEPROJECT}
DNSNAME=${DNSNAME}
EOF

# get your current azure subscription id
SUBSCRIPTION=$(az account show --query 'id' --output tsv)

# deploy for azure
az group create --resource-group ${RGNAME} \
    --location ${LOCATION} \
    --output table

az storage account create \
    --name ${STNAME} \
    --resource-group ${RGNAME} \
    --location ${LOCATION} \
    --kind StorageV2 \
    --sku Standard_LRS

az storage share create \
    --account-name ${STNAME} \
    --name ${STSHARENAME}

docker context create aci minecraft \
    --location ${LOCATION} \
    --resource-group ${RGNAME} \
    --subscription-id ${SUBSCRIPTION}

# docker login azure
# docker --context minecraft compose up

exit 0
