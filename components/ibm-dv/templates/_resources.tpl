{{- /*
Generate YAML for resource requests and limits.

Can specify only requests, or both requests and limits. In the case that only requests are specified, the values provided for the requests will be used for the limits.

__Values Used__
- none

__Config Values Used:__
- passed as argument

__Uses:__
- none

__Parameters input as an list of values:__
- the root context (required)
- config values map of resources (required)

__Usage:__
example values.yaml configuration
```
resources:
  componentA:
    requests:
      memory: 8Gi
      cpu: 1
  componentB:
    requests:
      memory: 4Gi
      cpu: 2
    limits:
      memory: 12Gi
      cpu: 4
```

used in template as follows:
```
containers:
  - name: componentA
{{- include "dv.helpers.resources" (list . .Values.resources.componentA) | indent 4 }}
  - name: componentB
{{- include "dv.helpers.resources" (list . .Values.resources.componentB) | indent 4 }}
```
*/}}
{{- define "dv.helpers.resources" -}}
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
