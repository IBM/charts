{{- /*
Helpers for docker image locations
*/ -}}
{{- define "alert-action-service.image.url" -}}
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
{{- define "alert-action-service.psp.securityContext" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  capabilities:
    drop:
      - ALL
{{- end -}}

{{- /*
Default URLs based on release name
*/ -}}
{{- define "alert-action-service.getAlertDetailsRelease" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedRelease := index . 1 -}}

  {{- if $userDefinedRelease -}}
    {{- $userDefinedRelease -}}
  {{ else }}
    {{- $root.Release.Name -}}
  {{- end -}}
{{- end -}}

{{- define "alert-action-service.getKafkaRelease" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedRelease := index . 1 -}}

  {{- if $userDefinedRelease -}}
    {{- $userDefinedRelease -}}
  {{ else }}
    {{- $root.Release.Name -}}
  {{- end -}}
{{- end -}}
