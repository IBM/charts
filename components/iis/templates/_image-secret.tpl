{{- define "image-secret" }}
{{- if .Values.imagePullSecrets }}
imagePullSecrets:
  - name: {{ .Values.imagePullSecrets.stage }}
  - name: {{ .Values.imagePullSecrets.acs }}
  - name: {{ .Values.imagePullSecrets.release }}
  - name: {{ .Values.imagePullSecrets.shop4info }}
  - name: {{ .Values.imagePullSecrets.finley }}
  - name: {{ .Values.imagePullSecrets.drcreds }}
{{- end }}
{{- end }}
