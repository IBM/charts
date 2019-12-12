{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-watson-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gateway.displayName" -}}
  {{- if and (.Values.addon.maxDeployments) (eq (int .Values.addon.maxDeployments) 1) -}}
    {{- printf "%s" .Values.addon.displayName }}
  {{- else -}}
    {{- printf "%s - %s" .Values.addon.displayName .Release.Name }}
  {{- end -}}
{{- end -}}

{{- define "gateway.shortDescription" -}}
  {{- if .Values.addon.shortDescription -}}
    {{- printf "%s" .Values.addon.shortDescription }}
  {{- else -}}
    {{- printf "{{.%s__short_description}}" (.Values.addon.serviceId | lower | replace "-" "_") }}
  {{- end -}}
{{- end -}}

{{- define "gateway.longDescription" -}}
  {{- if .Values.addon.longDescription -}}
    {{- printf "%s" .Values.addon.longDescription }}
  {{- else -}}
    {{- printf "{{.%s__long_description}}" (.Values.addon.serviceId | lower | replace "-" "_") }}
  {{- end -}}
{{- end -}}

{{- define "gateway.deployDocs" -}}
  {{- if .Values.addon.deployDocs -}}
    {{- printf "%s" .Values.addon.deployDocs }}
  {{- else -}}
    {{- printf "https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/%s-install.html" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "gateway.productDocs" -}}
  {{- if .Values.addon.productDocs -}}
    {{- printf "%s" .Values.addon.productDocs }}
  {{- else -}}
    {{- printf "https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/%s.html" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "gateway.apiReferenceDocs" -}}
  {{- if .Values.addon.apiReferenceDocs -}}
    {{- printf "%s" .Values.addon.apiReferenceDocs }}
  {{- else -}}
    {{- printf "https://cloud.ibm.com/apidocs/%s-data" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "gateway.gettingStartedDocs" -}}
  {{- if .Values.addon.gettingStartedDocs -}}
    {{- printf "%s" .Values.addon.gettingStartedDocs }}
  {{- else -}}
    {{- printf "https://cloud.ibm.com/docs/services/%s-data" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{/*
   A helper templates to support templated boolen values.
   Takes a value (and converts it into Boolean equivalet string value).
     If the value is of type Boolen, then if false renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.

  Usage: For keys like `autoscaling.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.autoscaling.enabled }}"

  Usage in templates:
    Instead of direct value test `{{ if .Values.autoscaling.enabled }}` one has to use {{ if include "gateway.booleanConvertor" (list .Values.autoscaling.enabled . ) }}
*/}}
{{- define "gateway.booleanConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VAULE renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  ------------------------BEGIN-OF-ADDON-HELPERS---------------------------
 */}}

{{- define "gateway.id" -}}
  {{- if and (.Values.addon.maxDeployments) (eq (int .Values.addon.maxDeployments) 1) -}}
    {{- printf "%s" .Values.addon.serviceId -}}
  {{- else -}}
    {{- printf "%s-%s" .Values.addon.serviceId .Release.Name  | lower -}}
  {{- end}}
{{- end -}}

{{- define "gateway.version" -}}
  {{- if .Values.addon.version -}}
    {{- .Values.addon.version -}}
  {{- else -}}
    {{- .Chart.Version -}}
  {{- end -}}
{{- end -}}
{{- define "gateway.addonService.svc" -}}
  {{- $service := (include "sch.names.fullCompName" (list . "gateway-svc")) -}}
  {{- printf "%s.%s.svc.%s" $service .Release.Namespace (tpl .Values.clusterDomain . ) -}}
{{- end -}}

{{/*
 URL Path where the gateway, auth, resource controller and account API mock will listen
 */}}
{{- define "gateway.addonService.path" -}}
  {{- $routingPath := (include "gateway.routing.path" .) -}}
  {{- printf "/watson%s" $routingPath }}
{{- end -}}

{{- define "gateway.addonService.endpoint" -}}
  {{- $url := (include "gateway.addonService.svc" .) -}}
  {{- printf "https://%s:%.0f" $url .Values.addonService.port -}}
{{- end -}}

{{/*
  -------------------------END-OF-ADDON-HELPERS---------------------------
 */}}

{{/*
  -------------------BEGING-OF-ROUTING-SERVICE-HELPERS--------------------
 Watson backend, additionalServices, tooling helpers
 Things like path, service name, port, namespace, etc..
 --------
 */}}
{{- define "gateway.routing.namespace" -}}
  {{- $routing := last . -}}
  {{- $root := first . -}}
  {{- if $routing.namespace -}}
    {{- $routing.namespace -}}
  {{- else if $root.Release.Namespace -}}
    {{- $root.Release.Namespace -}}
  {{- else -}}
     default
  {{- end -}}
{{- end -}}

{{- define "gateway.routing.path" -}}
  {{- printf "/%s/%s" .Values.addon.serviceId .Release.Name | lower }}
{{- end -}}

{{- define "gateway.account.name" -}}
  {{- if tpl .Values.serviceAccount.name . -}}
    {{- tpl .Values.serviceAccount.name . -}}
  {{- else -}}
    {{- if ne .Values.serviceAccount.name "" -}}
      {{- printf "%s" .Values.serviceAccount.name -}}
    {{- else -}}
      {{- printf "%s" (include "sch.names.fullCompName" (list . "gateway-svc")) | lower | trunc 63 -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "gateway.privileged-account.name" -}}
  {{- if tpl .Values.privilegedServiceAccount.name . -}}
    {{- tpl .Values.privilegedServiceAccount.name . -}}
  {{- else -}}
    {{- if ne .Values.privilegedServiceAccount.name "" -}}
      {{- printf "%s" .Values.privilegedServiceAccount.name -}}
    {{- else -}}
      {{- if (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        {{- printf "%s" "default" -}}
      {{- else -}}
        {{- printf "%s" (include "sch.names.fullCompName" (list . "gateway-privileged")) | lower | trunc 63 -}}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "gateway.routing.name" -}}
  {{- $root := first . -}}
  {{- $routing := last . -}}
  {{- if tpl $routing.name $root -}}
    {{- tpl $routing.name $root -}}
  {{- else if $routing.name -}}
    {{- $routing.name | trunc 63 -}}
  {{- else if $routing.nameTemplate -}}
    {{-  include $routing.nameTemplate $root | trunc 63 -}}
  {{- else -}}
     {{- required "Invalid configuration either 'name' or 'nameTemplate' needs to be specified" "" -}}
  {{- end -}}
{{- end -}}

{{- define "gateway.routing.svc" -}}
  {{- $root := first . -}}
  {{- $routing := last . -}}
  {{- $service := (include "gateway.routing.name" .) -}}
  {{- $namespace := (include "gateway.routing.namespace" .) -}}
  {{- printf "%s.%s.svc.%s" $service $namespace (tpl $root.Values.clusterDomain $root ) -}}
{{- end -}}

{{- define "gateway.icpDockerRepo" -}}
  {{- if tpl (.Values.global.icpDockerRepo | toString ) . -}}
    {{- $dockerRepo := ( tpl (.Values.global.icpDockerRepo | toString ) . ) | trimSuffix "/" -}}
    {{- printf "%s/" $dockerRepo -}}
  {{- else -}}
    {{- .Values.global.icpDockerRepo -}}
  {{- end -}}
{{- end -}}

{{- define "gateway.routing.scheme" -}}
  {{- $routing := last . -}}
  {{- if $routing.secure -}}
    {{- printf "https://" -}}
  {{- else -}}
    {{- printf "http://" -}}
  {{- end -}}
{{- end -}}

{{- define "gateway.routing.endpoint" -}}
  {{- $routing := last . -}}
  {{- $scheme := (include "gateway.routing.scheme" .) -}}
  {{- $url := (include "gateway.routing.svc" .) -}}
  {{- printf "%s%s:%.0f" $scheme $url $routing.port -}}
{{- end -}}


{{- define "gateway.cors" -}}
if ($request_method ~* "(GET|POST)") {
  add_header "Access-Control-Allow-Origin"  *;
}
# Preflighted requests
if ($request_method = OPTIONS ) {
  add_header "Access-Control-Allow-Origin"  *;
  add_header "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS, HEAD";
  add_header "Access-Control-Allow-Headers" "Origin, Accept, Content-Type, Content-Length, Authorization, X-Watson-UserInfo, X-Watson-Metadata, X-IBMCloud-SDK-Analytics, User-Agent";
  return 200;
}
{{- end -}}

{{/*
  -------------------------END-OF-ROUTING-HELPERS---------------------------
 */}}