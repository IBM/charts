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
{{- define "ibm-ace.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-ace-server-prod"
    meteringProd:
      productName: IBM App Connect Enterprise (Chargeable)
      productID: IBMAppConnectEnterprise_606f1a9feb4f4cbc85b17a637f6a6b24_chargeable
      productVersion: "11.0.0.6"
    meteringNonProd:
      productName: IBM App Connect Enterprise (Non-production) (Chargeable)
      productID: IBMAppConnectEnterprise_30fd0181a948441ebe3be59192171987_nonProd_chargeable
      productVersion: "11.0.0.6"
    labelType: prefixed
{{- end -}}
