{{- define "cloudant.releasename" -}}
{{- $name := default .Release.Name .Values.global.cloudant.releaseNameOverride -}}
{{- printf "%s-clt" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common labels for every component */}}
{{- define "global.labels" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
revision: {{ .Release.Revision | quote }}
app.kubernetes.io/component: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
namespace: {{ .Release.Namespace | quote }}
app.kubernetes.io/part-of: cloudant
{{- end -}}

{{- define "global.selector.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/component: {{ .Chart.Name | quote }}
namespace: {{ .Release.Namespace | quote }}
app.kubernetes.io/part-of: cloudant
{{- end -}}
