{{- define "ui.store_service" -}}
https://wcs-{{ .Release.Name }}.{{ .Release.Namespace }}:443/v1
{{- end -}}

{{- define "ui.languages" -}}
  {{- if .Values.languages -}}
    {{- .Values.languages -}}
  {{- else -}}
    {{- include "assistant.ui.languages" . -}}
  {{- end -}}
{{- end -}}

{{- define "ui.iam.secretName" -}}
  {{- if .Values.iam.secretName -}}
    {{- .Values.iam.secretName -}}
  {{- else -}}
        {{ .Release.Name }}-ui-iam
  {{- end -}}
{{- end -}}

{{- define "ui.ingress.path" -}}
    /assistant/{{- .Release.Name -}}
{{- end -}}

{{- define "ui.ibmcloudApi" -}}
    https://{{-  include "assistant.ingress.addonService.name" . -}}.{{- .Release.Namespace -}}:5000/api/ibmcloud
{{- end -}}

{{- define "ui.service_name" -}}
{{ .Release.Name }}-ui
{{- end -}}
