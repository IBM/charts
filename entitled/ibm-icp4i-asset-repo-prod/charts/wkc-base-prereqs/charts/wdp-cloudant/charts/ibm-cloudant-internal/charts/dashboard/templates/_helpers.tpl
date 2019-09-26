{{/* Dashboard-specific name */}}
{{- define "dashboard.name" -}}
{{- $name := default .Release.Name .Values.global.cloudant.releaseNameOverride -}}
{{- printf "%s-dashboard" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Dashboard-specific labels */}}
{{ define "dashboard.labels" -}}
{{ include "global.labels" . }}
app.kubernetes.io/name: fauxton
app.kubernetes.io/component: dashboard
{{- end }}

{{/* labels to identify pods for upgrades etc. Must not change between releases */}}
{{ define "dashboard.selector.labels" -}}
{{ include "global.selector.labels" . }}
app.kubernetes.io/name: fauxton
app.kubernetes.io/component: dashboard
{{- end }}

{{ define "dashboard.replicas" -}}
{{- if .Values.global.cloudant.singleNode -}}
    1
{{- else -}}
    {{ .Values.global.replicas.dashboard }}
{{- end -}}
{{- end }}