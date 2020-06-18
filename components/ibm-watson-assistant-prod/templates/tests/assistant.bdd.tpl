

{{- define "assistant.bdd" -}}
{{- $params := . -}}
{{- $tag := (include "sch.utils.getItem" (list $params 1 "@invalid")) -}}
{{- $root := first $params -}}
{{- include "sch.config.init" (list $root "assistant.sch.chart.config.values") }}
{{- $testKeyName := $tag | trimPrefix "@" }}
{{- $testKeyValue := pluck $testKeyName $root.Values.tests.bdd | first }}{{/* Getting the value of .Values.tests.bdd.$testKeyName */}}
{{- $testEnabled := tpl ( $testKeyValue | toString ) $root }}
{{- if eq "true" $testEnabled }}
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
apiVersion: v1
kind: Pod
metadata:
  name: "{{ $root.Release.Name }}-bdd-test-{{ trimPrefix "@" $tag | lower }}"
  annotations:
    "helm.sh/hook": test-success
{{- include "sch.metadata.annotations.metering" (list $root $root.sch.chart.metering "" "" "") | indent 4 }}
  labels:
    test: "bdd"
{{ include "sch.metadata.labels.standard" (list $root "bdd" (dict "icpdsupport/addOnName" $root.Values.global.addOnName "icpdsupport/app" "bdd" "icpdsupport/serviceInstanceId" ($root.Values.global.zenServiceInstanceId | int64))) | indent 4 }}
spec:
  restartPolicy: Never
  hostIPC: false
  hostNetwork: false
  hostPID: false
 
  containers:
  - name: test-bdd
    image: "{{ if tpl ( $root.Values.bdd.image.repository | toString ) $root }}{{ trimSuffix "/" (tpl ($root.Values.bdd.image.repository | toString ) $root | toString ) }}{{ end }}/{{ ( $root.Values.bdd.image.name  | toString ) }}:{{ ( $root.Values.bdd.image.tag | toString ) }}"
    imagePullPolicy: {{ $root.Values.bdd.image.pullPolicy | quote }}
    securityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      capabilities:
        drop:
          - ALL
      {{- if not ( $root.Capabilities.APIVersions.Has "security.openshift.io/v1" ) }}
      runAsUser: 2000
      {{- end }}
 
    metadata:
    command:
      - '/bin/sh'
      - '-c'
      - |
         #!/bin/bash
          
         set -xe
         
         if [ -z ${API_HOST:-} ] ; then
            echo "Error. API_HOST not set. Please setup API_HOST for example:"
            echo "  export API_HOST=https://localhost:443"
            echo ""
            exit 1
         fi
          
         export SERVICE_INSTANCE_GUID=$(cat /proc/sys/kernel/random/uuid)
         export ORGANIZATION_GUID=$(cat /proc/sys/kernel/random/uuid)
         export REGION_ID="bdd-test"
         
         # Generate new tenant 
         curl -X PUT \
           ${API_HOST}/csb/standard/v2/service_instances/${SERVICE_INSTANCE_GUID} \
             -H 'cache-control: no-cache' \
             -H 'content-type: application/json' \
             -H "x-bluemix-region: ${REGION_ID}" \
             -d "{\"organization_guid\" : \"${ORGANIZATION_GUID}\"}" -k
         
         # example systemProp.BM_USER_INFO="bluemix-instance-id=3efd74d3-3190-44ce-9b7d-14b1760bcb79;bluemix-region-id=us-south;bluemix-organization-guid=2ed23515-a749-4b7e-9a2e-e1c687d14e87"
         export BM_USER_INFO="bluemix-instance-id=${SERVICE_INSTANCE_GUID};bluemix-region-id=${REGION_ID};bluemix-organization-guid=${ORGANIZATION_GUID}"
         export TRAINING_MAXTIME=12
         
         set +e
         ./gradlew -q --no-daemon -g gradle.home runJar
         export RESULT=$?
         set -e
         
         # Cleanup = (Soft) delete the tenant
         curl -X DELETE \
           ${API_HOST}/csb/standard/v2/service_instances/${SERVICE_INSTANCE_GUID} \
           -H 'cache-control: no-cache' \
           -H 'content-type: application/json' \
           -H "x-bluemix-region: ${REGION_ID}" \
           -d "{\"organization_guid\" : \"${ORGANIZATION_GUID}\"}" -k
         
         # Print out the result and exit accordingly
         if [ -s "test_output/bdd/cucumber/regression_failures.txt" ]
         then
           echo "Error detected: test_output/bdd/cucumber/regression_failures.txt is not empty."
           echo "cat test_output/bdd/logs/VoyagerBDD.log"
           echo ""
           cat test_output/bdd/logs/VoyagerBDD.log
           echo "==================================================="
           echo ""
           echo "cat test_output/bdd/logs/VoyagerBDDResp.log"
           echo ""
           cat test_output/bdd/logs/VoyagerBDDResp.log
           echo "==================================================="
           echo ""
           echo "Overview: "
           cat test_output/bdd/cucumber/regression_failures.txt
           echo ""
           echo "====================================================="
           echo "*                                                   *"
           echo "*              BDD TESTS FAILED !!!                 *"
           echo "*                                                   *"
           echo "====================================================="
           echo ""
           exit 1
         elif [ ${RESULT} -ne 0 ] ; then
           echo "Gradle running BDD tests existed with error (non-zero exit code)."
           echo "    see logs for more details."
           echo "====================================================="
           echo "*                                                   *"
           echo "*              BDD TESTS FAILED !!!                 *"
           echo "*                                                   *"
           echo "====================================================="
           echo ""
         else
           echo ""
           echo "OK. test_output/bdd/cucumber/regression_failures.txt is empty. BDD tests passed."         
           echo ""
           echo "====================================================="
           echo "*                                                   *"
           echo "*              BDD TESTS PASSED !!!                 *"
           echo "*                                                   *"
           echo "====================================================="
           echo ""
           exit 0
         fi
    resources:
{{ toYaml $root.Values.bdd.resources | indent 6 }}
    env:
    - name: API_HOST
      value: "https://wcs-{{ $root.Release.Name }}:443"
    - name: CUCUMBER_TAGS
      value: "{{ $tag }}"
    - name: ICP_ENV
      value: "true"
    - name: "API_VERSION"
      value: "2019-02-28"
  serviceAccountName: {{ $root.Release.Name }}-restricted
  affinity:
{{ include "assistant.nodeAffinities" $root | indent 4 }}
{{- else if  eq "false" $testEnabled }}
# BDD Test {{ $tag }} has been disabled using .Values.test.bdd.$testKeyName
{{- else }}
  {{- fail ( printf "Invalid configuration: The value of .Values.test.bdd.%s is neither true or false as expected" $testKeyName) }}
{{- end }}
{{- end -}}
