{{ define "cogconfig-prospector" }}
- input_type: log
  paths:
  - '${LOG_DIRS}/cogconfig.log'
  multiline.pattern: '^[0-9]{2}/[0-9]{2}/[0-9]{4},'
  multiline.match: 'after'
  multiline.negate: true
{{- include "common-prospector" . | indent 2 }}
{{ end }}
