{{/* vim: set filetype=mustache: */}}

{{/*
Calculates the desired system_auth replication factor given the number of replicas.
*/}}

{{- define "cassandra.replicationFactor" -}}
  {{- if eq (.Values.global.cassandraNodeReplicas | toString) "environmentSizeDefault" }}
    {{- include "cassandra.comp.size.data" (list . "replicas") }}
  {{- else }}
    {{- .Values.global.cassandraNodeReplicas }}
  {{- end }}
{{- end }}

{{- define "cassandra.authSchemaReplicationFactor" -}}
{{- $replicationFactor := int (include "cassandra.replicationFactor" .) }}
{{- if gt $replicationFactor 3 -}}
  {{- printf "%d" 3 | quote }}
{{- else -}}
  {{- printf "%d" $replicationFactor | quote }}
{{- end -}}
{{- end -}}

{{- define "cassandra.getServiceAccountName" -}}
{{- if ne (toString .Values.serviceAccountName) "" -}}
  {{- tpl .Values.serviceAccountName . }}
{{- else if ne (toString .Values.global.rbac.serviceAccountName) "" -}}
  {{- tpl .Values.global.rbac.serviceAccountName . }}
{{- else if eq (toString .Values.global.rbac.create) "false" -}}
  {{- printf "%s" "default" | quote }}
{{- else -}}
  {{ include "sch.names.fullCompName" (list . "serviceaccount") }}
{{- end -}}
{{- end -}}

{{- define "cassandra.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}

{{- define "cassandra.getImage" -}}
{{- if or (eq (toString .Values.global.image.useTag) "true") (eq (toString .Values.image.digest) "") -}}
{{- printf "%s/%s:%s" (include "cassandra.getImageRepo" .) .Values.image.name .Values.image.tag -}}
{{- else -}}
{{- printf "%s/%s@%s" (include "cassandra.getImageRepo" .) .Values.image.name .Values.image.digest -}}
{{- end -}}
{{- end -}}
