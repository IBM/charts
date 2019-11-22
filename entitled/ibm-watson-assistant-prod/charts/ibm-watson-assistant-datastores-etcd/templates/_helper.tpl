
{{- define "assistant.etcd.secretName" -}}
{{ .Release.Name }}-assistant-etcd-creds
{{- end -}}
