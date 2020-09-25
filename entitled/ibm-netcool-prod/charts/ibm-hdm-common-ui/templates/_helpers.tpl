{{- /*
Helpers for calculating cluster.fqdns / URLs
*/ -}}
{{- define "ibm-hdm-common-ui.cluster.fqdn" -}}
  {{- if .Values.global.cluster.fqdn -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- else -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.ingress.host" -}}
  {{- $root := . -}}
  {{- $prefix := .Values.ingress.prefix -}}
  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressDomain := include "ibm-hdm-common-ui.cluster.fqdn" $root -}}

  {{- if $ingressGlobal.prefixWithReleaseName -}}
    {{- printf "%s.%s.%s" $prefix $root.Release.Name $ingressDomain | trimPrefix "." -}}
  {{- else -}}
    {{- printf "%s.%s" $prefix $ingressDomain | trimPrefix "." -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.ingress.baseurl" -}}
  {{- $ingressGlobal := .Values.global.ingress }}
  {{- $ingressComp := .Values.ingress }}
  {{- $ingressHost := include "ibm-hdm-common-ui.ingress.host" . -}}
  {{- if eq $ingressGlobal.port 443.0 -}}
    {{- printf "https://%s%s" $ingressHost $ingressComp.path | trimPrefix "." -}}
  {{- else -}}
    {{- printf "https://%s:%g%s" $ingressHost $ingressGlobal.port $ingressComp.path | trimPrefix "." -}}
  {{- end -}}
{{- end -}}


{{- /*
Helpers for docker image locations
*/ -}}
{{- define "ibm-hdm-common-ui.image.url" -}}
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
{{- define "ibm-hdm-common-ui.psp.securityContext" -}}
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
Generates init container command to generate secrets
*/ -}}
{{- define "ibm-hdm-common-ui.createSecrets" -}}
- /server/lib/bin/createSecrets.js
  {{ if eq .Values.integrations.ui.config.authenticationMode "watson-provider" }}
- --generateAdditionalSecrets=watson
  {{ end }}
{{- end -}}