#!/bin/bash

#list of files to write to

cv_tests_Dir="${1}../../"

FILES=("${cv_tests_Dir}test-01/values.yaml" "${cv_tests_Dir}test-02/values.yaml" "${cv_tests_Dir}test-03/values.yaml")

YPQA_URL="https://api.aiopenscale.test.cloud.ibm.com"
#YS1DEV_URL="https://aiopenscale-dev.us-south.containers.appdomain.cloud"

#[key from values.yaml, version/hearbeat endpoint]
CONFIGURATION=('configuration' '/v1/aios_configuration_service/heartbeat')
PAYLOAD_LOGGING=('payloadLogging' '/v1/aios_payload_logging_service/heartbeat')
PAYLOAD_LOGGING_API=('payloadLoggingApi' '/v1/aios_payload_logging_service_api/heartbeat')
DATAMART=('datamart' '/v1/aios_datamart_service_api/heartbeat')
FEEDBACK=('feedback' '/v1/aios_feedback_service/heartbeat')
EXPLAINABILITY=('explainability' '/v1/model_explanations/heartbeat')
FAIRNESS=('bias' '/v1/fairness_monitoring/heartbeat')
DRIFT=('drift' '/v1/model_drifts/heartbeat')
DASHBOARD=('dashboard' '/v1/aios_dashboard/heartbeat')
COMMON_API=('commonApi' '/v1/aios_common_api/heartbeat')
DISCOVERY=('mlGatewayDiscovery' '/v1/ml_instances/version')
SCHEDULING=('scheduling' '/v1/schedules/version')
FAST_PATH=('fastpath' '/v1/fastpath/heartbeat')
NOTIFICATION=('notification' '/v1/orchestration_notifications/version')
MRM=('mrm' '/v2/mrm/heartbeat')

#there is no bkpi_combined service in cloud. Just pull latest.
BKPI_COMBINED="bkpiCombined"

MLGATEWAY_SERVICE="mlGatewayService"

SERVICES=( "${CONFIGURATION[0]}" "${PAYLOAD_LOGGING[0]}" "${PAYLOAD_LOGGING_API[0]}" "${DATAMART[0]}" "${FEEDBACK[0]}" "${EXPLAINABILITY[0]}" "${FAIRNESS[0]}" 
"${DASHBOARD[0]}" "${COMMON_API[0]}" "${DRIFT[0]}" "${NOTIFICATION[0]}" "${MRM[0]}" )

ENDPOINT_URLS=( "${CONFIGURATION[1]}" "${PAYLOAD_LOGGING[1]}" "${PAYLOAD_LOGGING_API[1]}" "${DATAMART[1]}" "${FEEDBACK[1]}" "${EXPLAINABILITY[1]}" "${FAIRNESS[1]}" 
"${DASHBOARD[1]}" "${COMMON_API[1]}" "${DRIFT[1]}" "${NOTIFICATION[0]}" "${MRM[1]}" )

write_to_files () {
  for f in ${FILES[@]}
  do
    echo "$1" >> $f
  done
}

write_to_yamls () {
  for f in ${FILES[@]}
  do
    echo "${1}:" >> $f
    echo "@@image:" >> $f
    echo "@@@@tag: ${2}" >> $f
    
    word_to_replace="@"
    replacement=${word_to_replace//?/ }
    sed -i'.orig' "s,@,${replacement},g" "${f}"
  done
}

#add a newline
write_to_files "
"

#handle "our" services, and bkpi combined use latest.
OUR_SERVICES=( "${BKPI_COMBINED}" "${MLGATEWAY_SERVICE}" "${DISCOVERY[0]}" "${SCHEDULING[0]}" "${FAST_PATH[0]}" )
for SERVICE in ${OUR_SERVICES[@]}
do
    write_to_yamls ${SERVICE} "latest"
done

#handle other of services
for ((i=0; i<${#SERVICES[*]}; i++));
do

    _VERSION=$(curl -s ${YPQA_URL}${ENDPOINT_URLS[${i}]})
    VERSION=$(echo ${_VERSION} | jq -r '.build')

    if [ "${VERSION}x" = "nonex" ] || [ "${VERSION}x" = "nullx" ] || [ -z ${VERSION} ]
    then
        VERSION=$(echo ${_VERSION} | jq -r '.version')
    fi
    write_to_yamls ${SERVICES[${i}]} ${VERSION}
done