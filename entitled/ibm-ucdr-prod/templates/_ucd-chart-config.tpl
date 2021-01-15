{{/*
license  parameter must be set to true
*/}}
{{- define "{{ .Chart.Name }}.licenseValidate" -}}
  {{ $license := .Values.license.accept }}
  {{- if $license -}}
    true
  {{- end -}}
{{- end -}}

{{/* Determine which image to use given the product version. */}}
{{- define "{{ .Chart.Name }}.imageSpec" -}}
{{- if eq .Values.version "7.1.1.1" -}}
  cp.icr.io/cp/ibm-ucdr@sha256:5bb36c060520dab8d639539a305525caffcba4a9c7e34c60110269a32bcecd33
{{- else if eq .Values.version "7.1.1.0" -}}
  cp.icr.io/cp/ibm-ucdr@sha256:1a521134abc9496c0fe89534ac3cec48d34bb097f485d13c29a3b4f6c91c4849
{{- else if eq .Values.version "7.1.0.3" -}}
  cp.icr.io/cp/ibm-ucdr:7.1.0.3.1069281
{{- else -}}
  cp.icr.io/cp/ibm-ucdr:unknownProductVersion
{{- end -}}
{{- end -}}
