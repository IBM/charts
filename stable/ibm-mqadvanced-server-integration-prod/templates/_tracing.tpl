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

{{- define "odTracing.collector.host-port" -}}
{{- printf "%s:%s" "localhost" "14267" }}
{{- end -}}

{{- define "odTracing.collector.grpc-host-port" -}}
{{- printf "%s:%s" "localhost" "14250" }}
{{- end -}}

{{- define "odTracing.collector.elasticsearch-secret-name" -}}
{{- printf "%s" "icp4i-od-store-cred"  }}
{{- end -}}

{{- define "odTracing.collector.elasticsearch-url" -}}
{{- printf "%s%s%s:%s" "https://od-store-od." .Values.odTracingConfig.odTracingNamespace ".svc" "9200" }}
{{- end -}}

{{- define "icp4i-od.manager.registration-host" -}}
{{- printf "%s%s%s" "icp4i-od." .Values.odTracingConfig.odTracingNamespace ".svc" }}
{{- end -}}
