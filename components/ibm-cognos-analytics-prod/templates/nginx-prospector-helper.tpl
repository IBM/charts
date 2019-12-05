{{ define "nginx-prospector" }}
- input_type: log
  paths:
  - '/var/log/nginx/*.log'
{{- include "common-prospector" . | indent 2 }}
{{ end }}
