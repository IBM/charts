{{ define "p2pd-prospector" }}
- input_type: log
  paths:
  - '${LOG_DIRS}/*_messages.log'
  multiline.pattern: '^\[([0-9]{2}|[0-9]{1})\/([0-9]{2}|[0-9]{1})\/[0-9]{2}'
  multiline.match: 'after'
  multiline.negate: true
{{- include "common-prospector" . | indent 2 }}
{{ end }}
