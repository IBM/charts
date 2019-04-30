###############################################################################
# Copyright (c) 2017 IBM Corp.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
{{- /*
Chart specific config file for SLT (Shared Liberty Templates)

_slt-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the slt/_config.tpl file.
 
*/ -}}

{{- /*
"slt.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Liberty Templates.
*/ -}}
{{- define "slt.chart.config.values" -}}
slt:
  paths:
    wlpInstallDir: "/opt/ol/wlp"
  product:
    id: "OpenLiberty_67365423789_18002_151_00000"
    name: "Open Liberty"
    version: "19.0.0.3"
  kube:
    provider: Any
  parentChart: "open-liberty"
{{- end -}}

