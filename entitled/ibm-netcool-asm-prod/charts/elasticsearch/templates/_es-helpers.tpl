{{/*
When replicaCount is set to "environmentSizeDefault" then use 1 replica at size0
and 3 replicas at size1.
*/}}
{{- define "es.replicas" -}}
  {{- if eq ( .Values.global.elasticsearch.replicaCount | toString) "environmentSizeDefault" }}
    {{- if eq .Values.global.environmentSize "size0" }}
      {{- printf "%d" 1 }}
    {{- else -}}
      {{- printf "%d" 3 }}
    {{- end -}}
  {{- else }}
    {{- .Values.global.elasticsearch.replicaCount }}
  {{- end }}
{{- end }}
