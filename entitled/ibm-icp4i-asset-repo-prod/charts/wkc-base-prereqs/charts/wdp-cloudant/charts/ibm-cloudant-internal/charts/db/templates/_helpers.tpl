{{/* Database-specific labels */}}
{{ define "db.labels" -}}
{{ include "global.labels" . }}
app.kubernetes.io/name: dbcore
app.kubernetes.io/component: database
{{- end }}

{{/* labels to identify pods for upgrades etc. Must not change between releases */}}
{{ define "db.selector.labels" -}}
{{ include "global.selector.labels" . }}
app.kubernetes.io/name: dbcore
app.kubernetes.io/component: database
{{- end }}

{{ define "db.dbcore.replicas" -}}
{{- if .Values.global.cloudant.singleNode -}}
    1
{{- else -}}
    {{ .Values.global.cloudant.replicas }}
{{- end -}}
{{- end }}

{{ define "db.dbcore.cluster.r" -}}
{{- if .Values.global.cloudant.singleNode -}}
    1
{{- else -}}
    {{ .Values.dbpods.dbcore.cluster.r }}
{{- end -}}
{{- end }}

{{ define "db.dbcore.cluster.w" -}}
{{- if .Values.global.cloudant.singleNode -}}
    1
{{- else -}}
    {{ .Values.dbpods.dbcore.cluster.w }}
{{- end -}}
{{- end }}

{{ define "db.dbcore.cluster.n" -}}
{{- if .Values.global.cloudant.singleNode -}}
    1
{{- else -}}
    3
{{- end -}}
{{- end }}
