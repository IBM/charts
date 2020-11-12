{{- define "image-secret" }}
{{- if .Values.imagePullSecrets }}
imagePullSecrets:
  - name: {{ .Values.imagePullSecrets.stage }}
  - name: {{ .Values.imagePullSecrets.finley }}
  - name: {{ .Values.imagePullSecrets.release }}
{{- end }}
{{- end }}
