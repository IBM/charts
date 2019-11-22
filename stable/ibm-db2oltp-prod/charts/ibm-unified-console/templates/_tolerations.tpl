{{- define "uc.tolerations" }}
  {{- if .Values.customTolerations }}
{{ toYaml .Values.customTolerations }}
  {{- end }}
{{- end }}

