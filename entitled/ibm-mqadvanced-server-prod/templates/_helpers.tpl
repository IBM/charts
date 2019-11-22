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
{{/* vim: set filetype=mustache: */}}

{{/*
Check if tag contains specific platform suffix and if not set based on kube platform
*/}}
{{- define "platform" -}}
{{- if not .Values.arch }}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "ppc64le" }}
  {{- end -}}
  {{- if (eq "linux/s390x" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "s390x" }}
  {{- end -}}
{{- else -}}
  {{- printf "-%s" .Values.arch }}
{{- end -}}
{{- end -}}

{{/*
Return arch based on kube platform
*/}}
{{- define "arch" -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
  {{- if (eq "linux/s390x" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "s390x" }}
  {{- end -}}
{{- end -}}