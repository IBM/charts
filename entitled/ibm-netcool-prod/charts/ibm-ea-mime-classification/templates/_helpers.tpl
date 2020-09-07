{{- /*
Helpers for docker image locations
*/ -}}
{{- define "ibm-ea-mime-classification.image.url" -}}
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
{{- define "ibm-ea-mime-classification.psp.securityContext" -}}
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
{{- define "ibm-ea-mime-classification.geturl" -}}
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
