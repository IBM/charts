{{/*
license  parameter must be set to true
*/}}
{{- define "{{ .Chart.Name }}.licenseValidate" -}}
  {{ $license := .Values.license.accept }}
  {{- if $license  -}}
    true
  {{- end -}}
{{- end -}}

{{/* Determine which image to use given the product version. */}}
{{- define "{{ .Chart.Name }}.imageSpec" -}}
{{- if eq .Values.version "7.1.1.1" -}}
  cp.icr.io/cp/ibm-ucds@sha256:73130abeae856d2c3d08320d21ef3b677809419136c5880625206579ddb4af2c
{{- else if eq .Values.version "7.1.1.0" -}}
  cp.icr.io/cp/ibm-ucds@sha256:4f1fdc20a2cb4eb789188428d89652681a6299beb0b665ff910182dc82c5ee60
{{- else if eq .Values.version "7.1.0.3" -}}
  cp.icr.io/cp/ibm-ucds:7.1.0.3.1069281
{{- else -}}
  cp.icr.io/cp/ibm-ucds:unknownProductVersion
{{- end -}}
{{- end -}}
