{{- /*
Helpers for docker image locations
*/ -}}
{{- define "ibm-ea-dr-coordinator-service.image.url" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $imageParams := last $params -}}
  {{- $trimedRepo := ($root.Values.global.image.repository | trimAll "/") -}}

  {{- if $imageParams.repository -}}
    {{- printf "%s/%s/%s" $trimedRepo $imageParams.repository $imageParams.name | trimAll "/" -}}
  {{- else -}}
    {{- printf "%s/%s" $trimedRepo $imageParams.name | trimAll "/" -}}
  {{- end -}}
  {{- if or (eq (toString $root.Values.global.image.useTag) "true") (eq (toString $imageParams.digest) "") -}}
    {{- printf ":%s" $imageParams.tag -}}
  {{- else -}}
    {{- printf "@%s" $imageParams.digest -}}
  {{- end -}}
{{- end -}}



{{- /*
Common security context
*/ -}}
{{- define "ibm-ea-dr-coordinator-service.psp.securityContext" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL
{{- end -}}

{{- /*
Default URLs based on release name
*/ -}}
{{- define "ibm-ea-dr-coordinator-service.geturl" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedUrl := index . 1 -}}
  {{- $userDefinedRelease := index . 2 -}}
  {{- $urlTemplate := index . 3 -}}

  {{- if $userDefinedUrl -}}
    {{- $userDefinedUrl -}}
  {{- else if $userDefinedRelease -}}
    {{- printf $urlTemplate $userDefinedRelease -}}
  {{ else }}
    {{- printf $urlTemplate $root.Release.Name -}}
  {{- end -}}
{{- end -}}

{{/*
Use either image tag or digest
*/}}
{{- define "ibm-ea-dr-coordinator-service.image.suffix" -}}
{{- $root := (index . 0) -}}
{{- $image := (index . 1) -}}
{{- if or (eq (toString $root.Values.global.image.useTag) "true") (eq (toString $image.digest) "") -}}
{{- printf ":%s" $image.tag -}}
{{- else -}}
{{- printf "@%s" $image.digest -}}
{{- end -}}
{{- end -}}
