{{- define "ibm-watson-speech-prod.object-storage-endpoint" -}}
{{- $global := . -}}
{{- if $global.Values.global.datastores.minio.enabled -}}
https:// {{- $global.Release.Name -}} -ibm-minio-svc. {{- $global.Release.Namespace -}} :9000
{{- else -}}
{{ $global.Values.global.datastores.minio.endpoint }}
{{- end -}}
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

{{- define "initContainerResources" -}}
resources:
  requests:
    memory: "1024Mi"
    cpu: "500m"
  limits:
    memory: "1024Mi"
    cpu: "500m"
{{- end }}

{{- define "containerSecurityContext" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
{{- end }}
