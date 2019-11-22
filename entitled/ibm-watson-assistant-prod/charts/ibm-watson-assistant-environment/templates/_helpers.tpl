{{- define "ed.service_name" -}}
{{ .Release.Name }}-ed-mm
{{- end -}}

{{- define "spellcheck.service_name" -}}
conversation-spellchecker
{{- end -}}

{{- define "system_entities.service_name" -}}
conversation-system-entities
{{- end -}}

{{- define "tf_mm.service_name" -}}
{{ .Release.Name }}-tf-mm
{{- end -}}
