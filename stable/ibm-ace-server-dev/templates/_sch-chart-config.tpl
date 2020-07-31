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
    appName: "ibm-ace-server-dev"
    metering:
      productName: IBM App Connect Enterprise for Developers (Free)
      productID: IBMAppConnectEnterprise_f9e7010beec748fe98ff292138860707
      productVersion: "11.0.0.9"
      productMetric: VIRTUAL_PROCESSOR_CORE
      productChargedContainers: ''
    labelType: prefixed
{{- end -}}

{{/*

"sch.names.routeName" is a shared helper to build a route name based of the release
and namespace and route name.

Config Values Used: NA
  
Uses: NA
    
Parameters input as an array of one values:
  - the root context (required)
  - the release name to test (required)
  - the namespace name to test (required)
  - the route type to test (required)
Usage:
  {{- $routeName :=  include "sch.names.routeName" (list $root "MyRelease" "MyNamespace" "MyTypeOfRoute") -}}

*/}}
{{- define "sch.names.routeName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $releaseName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $namespaceName := (include "sch.utils.getItem" (list $params 2 "")) -}}
  {{- $namespaceLen := len $namespaceName -}}
  {{- $routeName := (include "sch.utils.getItem" (list $params 3 "")) -}}
  {{- $routeLen := len (printf "-%s-" $routeName) -}}
  {{- $maxLength := 62 -}}
  {{- $truncLength := (sub $maxLength $namespaceLen) -}}

  {{- $fullLengthString := (printf "%s-%s" $releaseName $routeName) -}}
  {{- $fullLengthResult :=  include "sch.utils.withinLength" (list $root $fullLengthString $truncLength) -}}

  {{- if $fullLengthResult -}}
    {{- $fullLengthResult | lower | trimSuffix "-" -}}
  {{- else -}}
    {{- $buildNameParms := (list) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" $fullLengthString "length" (sub $truncLength 1)) -}}
    {{- $shortResult := print (include "sch.names.buildName" $buildNameParms) -}}
    {{- $shortResult | lower | trimSuffix "-" | trimPrefix "-" -}}
  {{- end -}}
{{- end -}}