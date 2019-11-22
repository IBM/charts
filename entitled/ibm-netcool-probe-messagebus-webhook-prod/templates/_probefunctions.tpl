{{/*
Convert boolean to ON/OFF toggles."/".
*/}}
{{- define "ibm-netcool-probe-messagebus-webhook-prod.toOnOff" -}}
{{- $uppervalue := ( . | upper ) -}}
  {{- if (or (eq $uppervalue "OFF" ) (eq $uppervalue "FALSE")) }}
    {{- printf "%s" "OFF" }}
  {{- else if (or (eq $uppervalue "ON" ) (eq $uppervalue "TRUE")) }}
    {{- printf "%s" "ON" }}
  {{- else -}}
    {{- printf . }}
  {{- end -}}
{{- end -}}

{{/*
Process the URI component to remove redundant slashes "/".
*/}}
{{- define "ibm-netcool-probe-messagebus-webhook-prod.processUri" -}}
{{- if . -}}
  {{- $ori := .}}
  {{- $list := ( $ori | splitList "/") }}
  {{- range $list }}
    {{- if . -}}
      {{- printf  "%s%s" "/" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
This function constructs the scheme and host part of the URL depending
for local test. The "host" will be set to the service name.
*/}}
{{- define "ibm-netcool-probe-messagebus-webhook-prod.getProtocolAndServiceNameForTest" -}}
{{- include "sch.config.init" (list . "probe.sch.chart.config.values") -}}
{{- $compName :=  .sch.chart.components.probe.name -}}
{{- $svcName := include "sch.names.fullCompName" (list . $compName) }}
{{- $tlsenabled := include "ibm-netcool-probe-messagebus-webhook-prod.getportno" ( . ) }}
    {{- printf "%s%s.%s:%s" "http://" $svcName .Release.Namespace $tlsenabled }}
{{- end -}}


{{/*
Determines the final URI based on the following conditions: 
1. When Ingress is enabled and ingress host is unset:
  - Webhook URI/ReleaseName is used to make the Ingress path unique.
  - If WebhookURI is unset, the path is set to /probe/ReleaseName
2. When Ingress enabled and ingress host is set:
  - Webhook URI is used as is.
  - If Webhook URI is unset, it is set to /probe as default.
3. WHen Ingress is disabled:
  - Webhook URI is used as is
  - If Webhook URI is unset, it is set to /probe as default.
*/}}
{{- define "ibm-netcool-probe-messagebus-webhook-prod.getFinalURI" -}}
  {{-  if and .Values.webhook.uri .Values.ingress.enabled .Values.ingress.host -}}
    {{- include "ibm-netcool-probe-messagebus-webhook-prod.processUri" .Values.webhook.uri -}}
  {{- else if and .Values.ingress.enabled (not .Values.ingress.host ) }}
    {{- if not .Values.webhook.uri -}}
      {{- printf "%s/%s" "/probe" .Release.Name -}}
    {{- else -}}
      {{ $uri := printf "%s/%s" .Values.webhook.uri .Release.Name }}
      {{- include "ibm-netcool-probe-messagebus-webhook-prod.processUri" $uri -}}
    {{- end }}
  {{- else if and .Values.webhook.uri .Values.ingress.enabled (not .Values.ingress.host) }}
      {{- $uri := printf "%s/%s" .Values.webhook.uri .Release.Name }}
      {{- include "ibm-netcool-probe-messagebus-webhook-prod.processUri" $uri }}
  {{- else if not .Values.webhook.uri }}
    {{- printf "%s" "/probe" -}}
  {{- else -}}
    {{- include "ibm-netcool-probe-messagebus-webhook-prod.processUri" .Values.webhook.uri  }}
  {{- end -}}
{{- end -}}

{{- define "ibm-netcool-probe-messagebus-webhook-prod.checkfortls" -}}
{{- $tlsenabled := ( .| toString ) -}}
  {{- if (eq $tlsenabled "true" ) }}
    {{- printf "%s" "ON" }}
  {{- else -}}
    {{- printf "%s" "OFF" }}
  {{- end -}}
{{- end -}}

{{- define "ibm-netcool-probe-messagebus-webhook-prod.getportno" -}}
{{- $tlsenabled := include "ibm-netcool-probe-messagebus-webhook-prod.performvalidation" ( . ) -}}
  {{- if eq $tlsenabled "httpsNok" }}
    {{- printf "%s" "80" }}
  {{- else if eq $tlsenabled "httpsOk"  }}
    {{- printf "%s" "443" }}
  {{- end -}}
{{- end -}}

{{/*
This function is to validate whether Ingress and Ingress.tls are enabled.
The function also check for the Ingress host, so that Ingress.tls can 
use the Ingress host to sign the certificate.

Case 1) "HTTPS OK", it is valid to use HTTPS

Case 2) "HTTP NOT OK", default use case
*/}}

{{- define "ibm-netcool-probe-messagebus-webhook-prod.performvalidation" -}}
{{- if .Values.ingress.enabled -}}
  {{- if .Values.ingress.tls.enabled -}}
    {{- if .Values.ingress.host -}}
    {{- printf "%s" "httpsOk"}}
    {{- else -}}
    {{- printf "%s" "httpsNok"}}
    {{- end -}}
  {{- else -}}
  {{- printf "%s" "httpsNok"}}
  {{- end -}}
{{- else -}}
{{- printf "%s" "httpsNok"}}
{{- end -}}
{{- end -}}


