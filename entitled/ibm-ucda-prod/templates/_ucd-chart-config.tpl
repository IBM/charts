{{/*
license  parameter must be set to true
*/}}
{{- define "{{ .Chart.Name }}.licenseValidate" -}}
  {{ $license := .Values.license.accept }}
  {{- if $license -}}
    true
  {{- end -}}
{{- end -}}

{{/* Determine which image to use given the product version.
   * Fallback to image.repository and image.tag if version invalid. */}}
{{- define "{{ .Chart.Name }}.imageSpec" -}}
{{- if eq .Values.version "7.1.1.1" -}}
  cp.icr.io/cp/ibm-ucda@sha256:8a3c5815cdfc7852a74fb62ba5c4a954246a17a6947cefc561f29de2181081ae
{{- else if eq .Values.version "7.1.1.0" -}}
  cp.icr.io/cp/ibm-ucda@sha256:6b34cf4a0ce9b2f6398ea2bb41e8d614bba7befe8f5cbdce6d06d78c9207042d
{{- else if eq .Values.version "7.1.0.3" -}}
  cp.icr.io/cp/ibm-ucda:7.1.0.3.1069281
{{- else -}}
  cp.icr.io/cp/ibm-ucda:unknownProductVersion
{{- end -}}
{{- end -}}
