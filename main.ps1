#
# run all the deployment in correct order
#

az group deployment create --name <deployment name> -g <existing resource group name> --template-file .\network.template.json --parameters .\network.parameters.json
az group deployment create --name <deployment name> -g <existing resource group name> --template-file .\ipaclforexternallb.template.json --parameters .\ipaclforexternallb.parameters.json

az group deployment create --name <deployment name> -g <existing resource group name> --template-file .\ipaclforbastion.template.json --parameters .\ipaclforbastion.parameters.json


az group deployment create --name <deployment name> -g <existing resource group name> --template-file .\storage.template.json --parameters .\storage.parameters.json
az group deployment create --name <deployment name> -g <existing resource group name> --template-file .\bastion.template.json --parameters .\bastion.parameters.json

az group deployment create --name <deployment name> -g <existing resource group name> --template-file .\haproxy.template.json --parameters .\haproxy.parameters.json
az group deployment create --name <deployment name> -g <existing resource group name> --template-file .\mesos.template.json --parameters .\mesos.parameters.json