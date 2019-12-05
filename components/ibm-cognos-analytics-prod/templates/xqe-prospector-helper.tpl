{{ define "xqe-prospector" }}
- input_type: log
  paths:
  - '${LOG_DIRS}/XQE/*.xml'
  multiline.pattern: "^<event"
  multiline.match: 'after'
  multiline.negate: true
{{- include "common-prospector" . | indent 2 }}
{{ end }}
