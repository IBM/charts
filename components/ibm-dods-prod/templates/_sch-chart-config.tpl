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
      productID: "ICP4D-addon-DecisionOptimization_{{ .Chart.AppVersion | replace "." "" }}_perpetual_00000"
      productVersion: "{{ .Chart.AppVersion }}"
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      cloudpakVersion: "3.0.0"
      productChargedContainers: "All"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      serviceability.io/collection_type: "DEFAULT"
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
{{- end -}}
