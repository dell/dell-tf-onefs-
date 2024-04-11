#! /bin/bash

set -ex

eval "$(jq -r '@sh "AZURE_SUBSCRIPTION_ID=\(.arg1) VNET_RESOURCE_GROUP_NAME=\(.arg2) VNET=\(.arg3) PROVIDER=\(.arg4) GET_SUBNETS=\(.arg5)"')"

if [ "${GET_SUBNETS}" == "true" ]; then

	available_subnets=$(export AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}" RESOURCE_GROUP_NAME="${VNET_RESOURCE_GROUP_NAME}"; cloud-subnet-finder 16 2 "${VNET}" --cloud "${PROVIDER}")
	internal_subnet=$(echo "${available_subnets}" |jq -r .subnets[0])
	external_subnet=$(echo "${available_subnets}" |jq -r .subnets[1])

	subnets='{"azure_internal_subnet":"'"${internal_subnet}"'", 
			  "azure_external_subnet":"'"${external_subnet}"'"}\n'

else
	subnets='{"azure_internal_subnet":"null", 
			  "azure_external_subnet":"null"}\n'

fi
printf "$subnets"

