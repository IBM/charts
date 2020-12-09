{{- /*
Helpers for calculating cluster.fqdns / URLs
*/ -}}
{{- define "common-dash-auth-im-repo.cluster.fqdn" -}}
  {{- if .Values.global.cluster.fqdn -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- else -}}
    {{- .Values.global.cluster.fqdn -}}
  {{- end -}}
{{- end -}}

{{- define "common-dash-auth-im-repo.ingress.globalhost" -}}
  {{- $root := index . 0 -}}
  {{- $prefix := index . 1 -}}
  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressDomain := include "common-dash-auth-im-repo.cluster.fqdn" $root -}}

  {{- if $ingressGlobal.prefixWithReleaseName -}}
    {{- printf "%s%s%s.%s" $prefix $root.Values.global.urlDelimiter $root.Release.Name $ingressDomain | trimPrefix "." -}}
  {{- else -}}
    {{- printf "%s.%s" $prefix $ingressDomain | trimPrefix "." -}}
  {{- end -}}
{{- end -}}

{{- define "common-dash-auth-im-repo.ingress.host" -}}
  {{- $ingressComp := .Values.ingress }}

  {{- include "common-dash-auth-im-repo.ingress.globalhost" (list . $ingressComp.prefix) -}}
{{- end -}}

{{- define "common-dash-auth-im-repo.ingress.baseurl" -}}
  {{- $ingressGlobal := .Values.global.ingress }}
  {{- $ingressComp := .Values.ingress }}
  {{- $ingressHost := include "common-dash-auth-im-repo.ingress.host" . -}}

  {{- printf "https://%s:%g%s" $ingressHost $ingressGlobal.port $ingressComp.path | trimPrefix "." -}}
{{- end -}}


{{- /*
Helpers for docker image locations
*/ -}}
{{- define "common-dash-auth-im-repo.image.url" -}}
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
Default URLs based on release name
*/ -}}
{{- define "common-dash-auth-im-repo.geturl" -}}
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

{{- define "common-dash-auth-im-repo.getingressurl" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedUrl := index . 1 -}}
  {{- $userDefinedIngress := index . 2 -}}
  {{- $urlTemplate := index . 3 -}}

  {{- $ingressGlobal := $root.Values.global.ingress }}
  {{- $ingressHost := include "common-dash-auth-im-repo.ingress.globalhost" (list $root "") -}}
  {{- $ingressUrl := printf "https://%s:%g" $ingressHost $ingressGlobal.port | trimPrefix "." -}}

  {{- if $userDefinedUrl -}}
    {{- $userDefinedUrl -}}
  {{- else if $userDefinedIngress -}}
    {{- printf $urlTemplate $userDefinedIngress -}}
  {{ else }}
    {{- printf $urlTemplate $ingressUrl -}}
  {{- end -}}
{{- end -}}
