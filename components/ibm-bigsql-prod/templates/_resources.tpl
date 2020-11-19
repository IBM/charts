{{- /*
Generate YAML for resource requests and limits.

Can specify only requests, or both requests and limits. In the case that only requests are specified, the values provided for the requests will be used for the limits.
*/}}
{{- define "bigsql.helpers.resources" -}}
  {{- $params := . }}
  {{- $resourceParams := index $params 1 }}
resources:
{{- if hasKey $resourceParams "requests" }}
  requests:
  {{- if hasKey $resourceParams.requests "cpu" }}
    cpu: {{ $resourceParams.requests.cpu | quote}}
  {{- end }}
  {{- if hasKey $resourceParams.requests "memory" }}
    memory: {{ $resourceParams.requests.memory | quote }}
  {{- end }}
{{- end }}
{{- if hasKey $resourceParams "limits" }}
  limits:
  {{- if hasKey $resourceParams.limits "cpu" }}
    cpu: {{ $resourceParams.limits.cpu | quote}}
  {{- end }}
  {{- if hasKey $resourceParams.limits "memory" }}
    memory: {{ $resourceParams.limits.memory | quote }}
  {{- end }}
{{- else if hasKey $resourceParams "requests" }}
  limits:
  {{- if hasKey $resourceParams.requests "cpu" }}
    cpu: {{ $resourceParams.requests.cpu | quote}}
  {{- end }}
  {{- if hasKey $resourceParams.requests "memory" }}
    memory: {{ $resourceParams.requests.memory | quote }}
  {{- end }}
{{- end }}
{{- end -}}
