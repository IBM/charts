{{- /*
Helpers for docker image locations
*/ -}}
{{- define "ibm-ea-asm-normalizer.image.url" -}}
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

{{- define "ibm-ea-asm-normalizer.image.url-kafka" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $imageParams := last $params -}}
  {{- $trimedRepo := ($root.Values.global.kafkaImage.repository | trimAll "/") -}}

  {{- if $imageParams.repository -}}
    {{- printf "%s/%s/%s:%s" $trimedRepo $imageParams.repository $imageParams.nameAlt $imageParams.tag | trimAll "/" -}}
  {{- else -}}
    {{- printf "%s/%s:%s" $trimedRepo $imageParams.name $imageParams.tag | trimAll "/" -}}
  {{- end -}}
{{- end -}}

{{- /*
Common security context
*/ -}}
{{- define "ibm-ea-asm-normalizer.psp.securityContext" -}}
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
{{- define "ibm-ea-asm-normalizer.geturl" -}}
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
