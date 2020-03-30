# © Copyright IBM Corporation 2017, 2019
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
{{- define "ibm-mq.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-mq"
    meteringProd:
      productName: "IBM MQ Advanced"
      productID: "208423bb063c43288328b1d788745b0c"
      productVersion: "9.1.4"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "qmgr"
      productCloudpakRatio: "2:1"
      cloudpakName: "IBM Cloud Pak for Integration"
      cloudpakId: "c8b82d189e7545f0892db9ef2731b90d"
      cloudpakVersion: "2020.1.1"
    meteringNonProd:
      productName: "IBM MQ Advanced for Non-Production"
      productID: "21dfe9a0f00f444f888756d835334909"
      productVersion: "9.1.4"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "qmgr"
      productCloudpakRatio: "4:1"
      cloudpakName: "IBM Cloud Pak for Integration"
      cloudpakId: "c8b82d189e7545f0892db9ef2731b90d"
      cloudpakVersion: "2020.1.1"
{{- end -}}

{{- define "ibm-mq.sch.chart.config.metadata.labels" }}
{{- range $key, $value := .Values.metadata.labels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{- define "ibm-mq.chart.config.validate-multi-instance-persistence" -}}
{{- if or (eq .Values.queueManager.multiInstance false) (and .Values.queueManager.multiInstance .Values.persistence.enabled) -}}
ok
{{- end -}}
{{- end -}}
