{{/* vim: set filetype=mustache: */}}

{{- define "ibm-openpages.licenseValidate" -}}
  {{ $license := .Values.license }}
  {{- if $license -}}
    true
  {{- end -}}
{{- end -}}
