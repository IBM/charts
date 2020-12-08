{{- define "ibm-watson-speech-prod.object-storage-endpoint" -}}
{{- $global := . -}}
{{- if $global.Values.global.datastores.minio.enabled -}}
https:// {{- $global.Release.Name -}} -speech-to-text-minio-ibm-minio-svc. {{- $global.Release.Namespace -}} :9000
{{- else -}}
{{ $global.Values.global.datastores.minio.endpoint }}
{{- end -}}
{{- end -}}

{{- define "ibm-watson-speech.repo" -}}
{{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}
{{- end -}}



{{- define "speech-to-text-gdpr-data-deletion.serviceName" -}}
  {{- printf "%s-speech-to-text-gdpr-data-deletion" .Release.Name | lower }}
{{- end -}}

{{- define "speech-to-text-stt-customization.serviceName" -}}
  {{- printf "%s-speech-to-text-stt-customization" .Release.Name | lower }}
{{- end -}}

{{- define "speech-to-text-stt-async.serviceName" -}}
  {{- printf "%s-speech-to-text-stt-async" .Release.Name | lower }}
{{- end -}}

{{- define "speech-to-text-stt-runtime.serviceName" -}}
  {{- printf "%s-speech-to-text-stt-runtime" .Release.Name | lower }}
{{- end -}}

{{- define "text-to-speech-tts-customization.serviceName" -}}
  {{- printf "%s-text-to-speech-tts-customization" .Release.Name | lower }}
{{- end -}}

{{- define "text-to-speech-tts-runtime.serviceName" -}}
  {{- printf "%s-text-to-speech-tts-runtime" .Release.Name | lower }}
{{- end -}}

{{- define "ibm-watson-speech-prod.initContainerResources" -}}
resources:
  requests:
    memory: "1024Mi"
    cpu: "500m"
  limits:
    memory: "1024Mi"
    cpu: "500m"
{{- end }}

{{- define "java-services.containerSecurityContext" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
{{- end }}

{{/*
affinity settings. Default values are in _sch-chart-config.tpl
*/}}
{{- define "ibm-watson-speech-prod.affinity" -}}
  {{- if .Values.affinity }}
    {{- $affinity := .Values.affinity -}}
    {{- if kindIs "map" $affinity }}
{{ toYaml $affinity }}
    {{- else }}
{{ tpl $affinity . }}
    {{- end -}}
  {{- else }}
{{- include "sch.affinity.nodeAffinity" (list . ) }}
  {{- end }}
{{- end -}}

{{- define "speech-services.meteringLabels" -}}
icpdsupport/addOnId: "{{ ( .Values.global.addonId ) }}"
icpdsupport/serviceInstanceId: "{{ ( .Values.global.zenServiceInstanceId | int64 ) }}"
{{- end -}}
