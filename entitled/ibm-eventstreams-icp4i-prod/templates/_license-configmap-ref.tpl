{{- define "license.accept.ref" }}
  - name: license-accept
    configMap:
      name: {{ .Release.Name }}-license-accept
{{- end }}