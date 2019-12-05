{{ define "cognosserver-prospector" }}
- input_type: log
  paths:
  - '${LOG_DIRS}/cognosserver.log'
  multiline.pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
  multiline.match: 'after'
  multiline.negate: true
{{- include "common-prospector" . | indent 2 }}
{{ end }}
