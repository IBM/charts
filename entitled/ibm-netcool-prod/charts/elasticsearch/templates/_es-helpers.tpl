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

{{- define "es.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}

{{/*
Sets the resources required for helm test pods and initContainers
*/}}
{{- define "es.minimalPodResources" -}}
requests:
  memory: "64Mi"
  cpu: "100m"
limits:
  memory: "64Mi"
  cpu: "100m"
{{- end -}}

{{- define "es.containerSecurityContext" -}}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: true
runAsUser: 1000
capabilities:
  drop:
  - ALL
{{- end -}}

