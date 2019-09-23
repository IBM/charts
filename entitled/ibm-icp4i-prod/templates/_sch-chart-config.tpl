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
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: {{ template "icip-navigator.name" . }}
    meteringProd:
      productName: IBM Cloud Pak for Integration
      productID: 5737_I89_ICP4I_nonChargeable
      productVersion: 2019.3.1
    meteringNonProd:
      productName: IBM Cloud Pak for Integration (non-production)
      productID: 5737_I89_ICP4I_nonProd_nonChargeable
      productVersion: 2019.3.1
    components:
      dashboard:
        name: "dashboard"
{{- end -}}
