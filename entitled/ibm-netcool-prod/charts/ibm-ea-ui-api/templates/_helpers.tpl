{{- /*
Helpers for calculating cluster.fqdns / URLs
*/ -}}
{{- define "ibm-ea-ui-api.cluster.fqdn" -}}
  {{- if .Values.global.cluster.fqdn -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- else -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-ea-ui-api.ingress.globalhost" -}}
  {{- $root := index . 0 -}}
  {{- $prefix := index . 1 -}}
  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressDomain := include "ibm-ea-ui-api.cluster.fqdn" $root -}}

  {{- if $ingressGlobal.prefixWithReleaseName -}}
    {{- printf "%s.%s.%s" $prefix $root.Release.Name $ingressDomain | trimPrefix "." -}}
  {{- else -}}
    {{- printf "%s.%s" $prefix $ingressDomain | trimPrefix "." -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-ea-ui-api.ingress.host" -}}
  {{- $ingressComp := .Values.ingress }}

  {{- include "ibm-ea-ui-api.ingress.globalhost" (list . $ingressComp.prefix) -}}
{{- end -}}

{{- define "ibm-ea-ui-api.ingress.baseurl" -}}
  {{- $ingressGlobal := .Values.global.ingress }}
  {{- $ingressComp := .Values.ingress }}
  {{- $ingressHost := include "ibm-ea-ui-api.ingress.host" . -}}

  {{- printf "https://%s:%g%s" $ingressHost $ingressGlobal.port $ingressComp.path | trimPrefix "." -}}
{{- end -}}


{{- /*
Helpers for docker image locations
*/ -}}
{{- define "ibm-ea-ui-api.image.url" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $imageParams := last $params -}}
  {{- $trimedRepo := ($root.Values.global.image.repository | trimAll "/") -}}

  {{- if $imageParams.repository -}}
    {{- printf "%s/%s/%s:%s" $trimedRepo $imageParams.repository $imageParams.name $imageParams.tag | trimAll "/" -}}
  {{- else -}}
    {{- printf "%s/%s:%s" $trimedRepo $imageParams.name $imageParams.tag | trimAll "/" -}}
  {{- end -}}
{{- end -}}

{{- /*
Common security context
*/ -}}
{{- define "ibm-ea-ui-api.psp.securityContext" -}}
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
{{- define "ibm-ea-ui-api.geturl" -}}
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

{{- define "ibm-ea-ui-api.getingressurl" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedUrl := index . 1 -}}
  {{- $userDefinedIngress := index . 2 -}}
  {{- $urlTemplate := index . 3 -}}

  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressHost := include "ibm-ea-ui-api.ingress.globalhost" (list $root "") -}}
  {{- $ingressUrl := printf "https://%s:%g" $ingressHost $ingressGlobal.port | trimPrefix "." -}}

  {{- if $userDefinedUrl -}}
    {{- $userDefinedUrl -}}
  {{- else if $userDefinedIngress -}}
    {{- printf $urlTemplate $userDefinedIngress -}}
  {{ else }}
    {{- printf $urlTemplate $ingressUrl -}}
  {{- end -}}
{{- end -}}
