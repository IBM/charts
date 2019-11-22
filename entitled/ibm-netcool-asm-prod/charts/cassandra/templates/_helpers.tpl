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
