{{- define "assistant.serviceAccount.imagePullSecrets" -}}
imagePullSecrets:
  - name: sa-{{ .Release.Namespace }}
  {{- if tpl .Values.global.image.pullSecret . }}
  - name: {{ tpl .Values.global.image.pullSecret . }}
  {{- end }}
{{- end -}}
