{{- /*
Helpers for calculating cluster.fqdns / URLs
*/ -}}
{{- define "ibm-noi-alert-details.cluster.fqdn" -}}
  {{- if .Values.global.cluster.fqdn -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- else -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-noi-alert-details.ingress.globalhost" -}}
  {{- $root := index . 0 -}}
  {{- $prefix := index . 1 -}}
  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressDomain := include "ibm-noi-alert-details.cluster.fqdn" $root -}}

  {{- if $ingressGlobal.prefixWithReleaseName -}}
    {{- printf "%s.%s.%s" $prefix $root.Release.Name $ingressDomain | trimPrefix "." -}}
  {{- else -}}
    {{- printf "%s.%s" $prefix $ingressDomain | trimPrefix "." -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-noi-alert-details.ingress.host" -}}
  {{- $ingressComp := .Values.ingress }}

  {{- include "ibm-noi-alert-details.ingress.globalhost" (list . $ingressComp.prefix) -}}
{{- end -}}

{{- define "ibm-noi-alert-details.ingress.baseurl" -}}
  {{- $ingressGlobal := .Values.global.ingress }}
  {{- $ingressComp := .Values.ingress }}
  {{- $ingressHost := include "ibm-noi-alert-details.ingress.host" . -}}

  {{- printf "https://%s:%g%s" $ingressHost $ingressGlobal.port $ingressComp.path | trimPrefix "." -}}
{{- end -}}


{{- /*
Helpers for docker image locations
*/ -}}
{{- define "ibm-noi-alert-details.image.url" -}}
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
{{- define "ibm-noi-alert-details.psp.securityContext" -}}
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

{{- define "ibm-noi-alert-details.spec.securityContext" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
{{- end -}}

{{- /*
Default URLs based on release name
*/ -}}
{{- define "ibm-noi-alert-details.geturl" -}}
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

{{- define "ibm-noi-alert-details.getingressurl" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedUrl := index . 1 -}}
  {{- $userDefinedIngress := index . 2 -}}
  {{- $urlTemplate := index . 3 -}}

  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressHost := include "ibm-noi-alert-details.ingress.globalhost" (list $root "") -}}
  {{- $ingressUrl := printf "https://%s:%g" $ingressHost $ingressGlobal.port | trimPrefix "." -}}

  {{- if $userDefinedUrl -}}
    {{- $userDefinedUrl -}}
  {{- else if $userDefinedIngress -}}
    {{- printf $urlTemplate $userDefinedIngress -}}
  {{ else }}
    {{- printf $urlTemplate $ingressUrl -}}
  {{- end -}}
{{- end -}}
