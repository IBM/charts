# © Copyright IBM Corporation 2019
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-dods-prod.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-dods-prod"
    labelType: "prefixed"      
    metering:
      productName: "{{ .Chart.Description }}"
      productID: "497aaae00a3f402dbcbb6ee00d1b924b"
      productVersion: "{{ .Chart.AppVersion }}"
      cloudpakName: "IBM Watson Studio Premium Extension for IBM Cloud Pak for Data"
      cloudpakId: "497aaae00a3f402dbcbb6ee00d1b924b"
      cloudpakInstanceId: "{{ .Values.global.cloudpakInstanceId }}"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "All"
      productCloudpakRatio: "1:1"

    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - {{ .Values.global.architecture }}
    securityContextPodWAS:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000320900
    securityContextPodNode:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000320900
    securityContextPodSetup:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000330999 
        runAsGroup: 1000        
    securityContextContainerNoRoot:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL            
    components:
      ddCognitive:
        compName: "dd-cognitive"
      ddScenarioApi:
        compName: "dd-scenario-api"
      ddScenarioUi:
        compName: "dd-scenario-ui"
      ddInit:
        compName: "dd-init"
      ddUninstall:
        compName: "dd-uninstall"
      ddConfig:
        compName: "dd-config"        
{{- end -}}
