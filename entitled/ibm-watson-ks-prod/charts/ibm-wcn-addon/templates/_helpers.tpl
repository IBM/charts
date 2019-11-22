{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-wcn-addon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "wcn-addon.displayName" -}}
  {{- if and (.Values.addon.maxDeployments) (eq (int .Values.addon.maxDeployments) 1) -}}
    {{- printf "%s" .Values.addon.displayName }}
  {{- else -}}
    {{- printf "%s - %s" .Values.addon.displayName .Release.Name }}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.shortDescription" -}}
  {{- if .Values.addon.shortDescription -}}
    {{- printf "%s" .Values.addon.shortDescription }}
  {{- else -}}
    {{- printf "{{.%s__short_description}}" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.longDescription" -}}
  {{- if .Values.addon.longDescription -}}
    {{- printf "%s" .Values.addon.longDescription }}
  {{- else -}}
    {{- printf "{{.%s__long_description}}" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.deployDocs" -}}
  {{- if .Values.addon.deployDocs -}}
    {{- printf "%s" .Values.addon.deployDocs }}
  {{- else -}}
    {{- printf "https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/%s-install.html" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.productDocs" -}}
  {{- if .Values.addon.productDocs -}}
    {{- printf "%s" .Values.addon.productDocs }}
  {{- else -}}
    {{- printf "https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/%s.html" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.apiReferenceDocs" -}}
  {{- if .Values.addon.apiReferenceDocs -}}
    {{- printf "%s" .Values.addon.apiReferenceDocs }}
  {{- else -}}
    {{- printf "https://cloud.ibm.com/apidocs/%s-data" .Values.addon.serviceId }}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.gettingStartedDocs" -}}
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
    Instead of direct value test `{{ if .Values.autoscaling.enabled }}` one has to use {{ if include "wcn-addon.booleanConvertor" (list .Values.autoscaling.enabled . ) }}
*/}}
{{- define "wcn-addon.booleanConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VAULE renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  ------------------------BEGIN-OF-ADDON-HELPERS---------------------------
 */}}

{{- define "wcn-addon.id" -}}
  {{- if and (.Values.addon.maxDeployments) (eq (int .Values.addon.maxDeployments) 1) -}}
    {{- printf "%s" .Values.addon.serviceId -}}
  {{- else -}}
    {{- printf "%s-%s" .Values.addon.serviceId .Release.Name  | lower -}}
  {{- end}}
{{- end -}}

{{- define "wcn-addon.version" -}}
  {{- if .Values.addon.version -}}
    {{- .Values.addon.version -}}
  {{- else -}}
    {{- .Chart.Version -}}
  {{- end -}}
{{- end -}}
{{- define "wcn-addon.addonService.svc" -}}
  {{- $service := (include "sch.names.fullCompName" (list . "addon")) -}}
  {{- printf "%s.%s.svc.%s" $service .Release.Namespace (tpl .Values.clusterDomain . ) -}}
{{- end -}}

{{/*
 URL Path where the addon, auth, resource controller and account API mock will listen
 */}}
{{- define "wcn-addon.addonService.path" -}}
  {{- $routingPath := (include "wcn-addon.routing.path" .) -}}
  {{- printf "/watson%s" $routingPath }}
{{- end -}}

{{- define "wcn-addon.addonService.endpoint" -}}
  {{- $url := (include "wcn-addon.addonService.svc" .) -}}
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
{{- define "wcn-addon.routing.namespace" -}}
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

{{- define "wcn-addon.routing.path" -}}
  {{- printf "/%s/%s" .Values.addon.serviceId .Release.Name | lower }}
{{- end -}}

{{- define "wcn-addon.account.name" -}}
  {{- if tpl .Values.serviceAccount.name . -}}
    {{- tpl .Values.serviceAccount.name . -}}
  {{- else -}}
    {{- if ne .Values.serviceAccount.name "" -}}
      {{- printf "%s" .Values.serviceAccount.name -}}
    {{- else -}}
      {{- printf "%s" (include "sch.names.fullCompName" (list . "addon-svc")) | lower | trunc 63 -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.privileged-account.name" -}}
  {{- if tpl .Values.privilegedServiceAccount.name . -}}
    {{- tpl .Values.privilegedServiceAccount.name . -}}
  {{- else -}}
    {{- if ne .Values.privilegedServiceAccount.name "" -}}
      {{- printf "%s" .Values.privilegedServiceAccount.name -}}
    {{- else -}}
      {{- if (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        {{- printf "%s" "default" -}}
      {{- else -}}
        {{- printf "%s" (include "sch.names.fullCompName" (list . "addon-privileged")) | lower | trunc 63 -}}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.routing.name" -}}
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

{{- define "wcn-addon.routing.svc" -}}
  {{- $root := first . -}}
  {{- $routing := last . -}}
  {{- $service := (include "wcn-addon.routing.name" .) -}}
  {{- $namespace := (include "wcn-addon.routing.namespace" .) -}}
  {{- printf "%s.%s.svc.%s" $service $namespace (tpl $root.Values.clusterDomain $root ) -}}
{{- end -}}

{{- define "wcn-addon.icpDockerRepo" -}}
  {{- if tpl (.Values.global.icpDockerRepo | toString ) . -}}
    {{- $dockerRepo := ( tpl (.Values.global.icpDockerRepo | toString ) . ) | trimSuffix "/" -}}
    {{- printf "%s/" $dockerRepo -}}
  {{- else -}}
    {{- .Values.global.icpDockerRepo -}}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.routing.scheme" -}}
  {{- $routing := last . -}}
  {{- if $routing.secure -}}
    {{- printf "https://" -}}
  {{- else -}}
    {{- printf "http://" -}}
  {{- end -}}
{{- end -}}

{{- define "wcn-addon.routing.endpoint" -}}
  {{- $routing := last . -}}
  {{- $scheme := (include "wcn-addon.routing.scheme" .) -}}
  {{- $url := (include "wcn-addon.routing.svc" .) -}}
  {{- printf "%s%s:%.0f" $scheme $url $routing.port -}}
{{- end -}}

{{/*
  -------------------------END-OF-ROUTING-HELPERS---------------------------
 */}}