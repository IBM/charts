{{- define "mongodbSecurityContext" }}
securityContext:
  runAsNonRoot: false
  runAsUser: 0
{{- end }}
