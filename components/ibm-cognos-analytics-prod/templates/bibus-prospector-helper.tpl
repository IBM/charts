{{ define "bibus-prospector" }}
- input_type: log
  paths:
  - '${LOG_DIRS}/BIBusTKServerMain.log'
  multiline.pattern: '^\s'
  multiline.match: 'after'
  multiline.negate: true
{{- include "common-prospector" . | indent 2 }}
{{ end }}
