#!/bin/bash

####################################
### PLEASE CHANGE THIS VARIABLES ###
####################################
LOCATION='japaneast'             # azure deploy region
RGNAME='zabbix-aci-container-rg' # resource group name

COMPOSEPROJECT='aci-zabbix' # ACI resource name
MYSQLNAME='ktkrmysql001'    # MySQL server name (unique scope is global)
DNSNAME='ktkrzabbix001'     # DNS name (unique scope is global))
####################################

cat <<EOF >./.env
COMPOSE_PROJECT_NAME=${COMPOSEPROJECT}
DNSNAME=${DNSNAME}
EOF

cat <<EOF >./.MYSQL_HOST
DB_SERVER_HOST=${MYSQLNAME}.mysql.database.azure.com
EOF

if [ ! -f ./.MYSQL_PASSWORD ]; then
    echo -n "MySQL password: "
    read -s DBPASS
    echo
    cat <<EOF >./.MYSQL_PASSWORD
MYSQL_PASSWORD=${DBPASS}
EOF
fi

# get your current azure subscription id
SUBSCRIPTION=$(az account show --query 'id' --output tsv)

# deploy for azure
az group create --resource-group ${RGNAME} \
    --location ${LOCATION} \
    --output table

az mysql flexible-server create --resource-group ${RGNAME} \
    --name ${MYSQLNAME} \
    --admin-user dbadmin \
    --admin-password ${DBPASS} \
    --location ${LOCATION} \
    --public-access '0.0.0.0' \
    --sku-name 'Standard_B1s' \
    --storage-size 20 \
    --tier Burstable \
    --version 8.0.21

az mysql flexible-server parameter set --resource-group ${RGNAME} \
    --server-name ${MYSQLNAME} \
    --name 'require_secure_transport' \
    --value 'OFF'

docker context create aci zabbix \
    --location ${LOCATION} \
    --resource-group ${RGNAME} \
    --subscription-id ${SUBSCRIPTION}

# docker login azure
# docker --context zabbix compose up

exit 0
