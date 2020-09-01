{{- define "mongodbSecurityContext" }}
securityContext:
  capabilities:
    drop:
    - ALL
{{- end }}
