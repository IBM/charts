{{- define "ed.service_name" -}}
{{ .Release.Name }}-ed-mm
{{- end -}}

{{- define "spellcheck.service_name.en" -}}
{{ .Release.Name }}-spellchecker-en
{{- end -}}

{{- define "spellcheck.service_name.fr" -}}
{{ .Release.Name }}-spellchecker-fr
{{- end -}}

{{- define "system_entities.service_name" -}}
{{ .Release.Name }}-system-entities
{{- end -}}

{{- define "tf_mm.service_name" -}}
{{ .Release.Name }}-tf-mm
{{- end -}}

{{- define "nlu.service_name" -}}
{{ .Release.Name }}-nlu
{{- end -}}

{{- define "tas.service_name" -}}
{{ .Release.Name }}-tas
{{- end -}}

{{- define "master.service_name" -}}
{{ .Release.Name }}-master
{{- end -}}

{{- define "clu_embedding_service.service_name" -}}
{{ .Release.Name }}-clu-embedding-service
{{- end -}}
