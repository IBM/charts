{{- define "alm.getCassandraReplicationFactor" -}}
{{- if gt .Values.global.cassandraNodeReplicas 3.0 }}
{{- printf "%d" 3 -}}
{{- else -}}
{{- printf "%d" (int .Values.global.cassandraNodeReplicas) -}}
{{- end -}}
{{- end -}}
