{{- define "assistant.dialog.etcd.ssl_mode" -}}
  {{- if  hasPrefix "http://" (include "assistant.etcd.endpoints" . ) -}}
    NONE
  {{- else -}}
    ENABLED
  {{- end -}}
{{- end -}}


{{- define "dialog.service_name" -}}
{{ .Release.Name }}-dialog
{{- end -}}