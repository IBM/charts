{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-watson-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gateway.displayName" -}}
    {{- printf "%s" .Values.addon.displayName }}
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


{{- define "gateway.get-name-or-use-default" -}}
  {{- $root := first . -}}
  {{- $components := pluck "components" $root.sch.chart | first -}}
  {{- if hasKey $components "watson-gateway" -}}
    {{- if eq ((index $components "watson-gateway").name) "" -}}
      {{- printf "%s" (last .) -}}
    {{- else -}}
      {{- printf "%s-%s" (last .) (index $components "watson-gateway").name }}
    {{- end -}}
  {{- else -}}
    {{- printf "%s" (last .) }}
  {{- end -}}
{{- end -}}

{{- define "gateway.image-name-extract" -}}
{{- $parts := splitList "/" . -}}
{{- printf "%s" (last $parts) -}}
{{- end -}}


{{/*
affinity settings. Defaults values are in _sch-chart-config.tpl
*/}}
{{- define "gateway.affinity" -}}
  {{- $allParams := . }}
  {{- $root      := first . }}
  {{- $details   := first (rest . ) }}
  {{- $_         := set $root "affinityDetails" $details -}}

  {{- if $root.Values.affinity }}
    {{- $affinity := $root.Values.affinity -}}
    {{- if kindIs "map" $affinity }}
{{ toYaml $affinity }}
    {{- else }}
{{ tpl $affinity $root }}
    {{- end -}}
  {{- else }}
{{- include "sch.affinity.nodeAffinity" (list $root ) }}
  {{- end }}
{{- end -}}


{{- define "gateway.gwAntiAffinity" -}}
  {{- $root    := first . }}
  {{- $details := first (rest .) }}
  {{- $antiAffinityPolicy := tpl ($root.Values.addonService.antiAffinity.policy | toString ) $root -}}
  {{- if eq $antiAffinityPolicy "hard" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: {{ tpl ($root.Values.addonService.antiAffinity.topologyKey | toString ) $root }}
      labelSelector:
        matchLabels:
{{ include "sch.metadata.labels.standard" (list $root $details.component) | indent 10 }}
  {{- else if eq $antiAffinityPolicy "soft" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      podAffinityTerm:
        topologyKey: {{ tpl ($root.Values.addonService.antiAffinity.topologyKey | toString ) $root }}
        labelSelector:
          matchLabels:
{{ include "sch.metadata.labels.standard" (list $root $details.component) | indent 12 }}

  {{- end }}
{{- end }}
{{/*
  ------------------------BEGIN-OF-ADDON-HELPERS---------------------------
 */}}

{{- define "gateway.id" -}}
    {{- printf "%s" .Values.addon.serviceId -}}
{{- end -}}

{{- define "gateway.version" -}}
  {{- if .Values.addon.version -}}
    {{- .Values.addon.version -}}
  {{- else -}}
    {{- .Chart.Version -}}
  {{- end -}}
{{- end -}}
{{- define "gateway.addonService.svc" -}}
  {{- $compName := include "gateway.get-name-or-use-default" (list . "gateway-svc") -}}
  {{- $service := (include "sch.names.fullCompName" (list . $compName)) -}}
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

{{- define "gateway.addonService.zenNamespace" -}}
  {{- if .Values.global.zenControlPlaneNamespace -}}
    {{- .Values.global.zenControlPlaneNamespace -}}
  {{- else -}}
    {{ tpl (.Values.addonService.zenNamespace | toString ) . }}
  {{- end -}}
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

{{- define "gateway.routing.basePath" -}}
  {{- printf "/%s" .Values.addon.serviceId | lower }}
{{- end -}}

{{- define "gateway.routing.path" -}}
  {{- printf "%s/%s" (include "gateway.routing.basePath" .) .Release.Name | lower }}
{{- end -}}

{{- define "gateway.account.name" -}}
  {{- if tpl .Values.serviceAccount.name . -}}
    {{- tpl .Values.serviceAccount.name . -}}
  {{- else -}}
    {{- if ne .Values.serviceAccount.name "" -}}
      {{- printf "%s" .Values.serviceAccount.name -}}
    {{- else -}}
      {{- $compName := include "gateway.get-name-or-use-default" (list . "gw-sa") -}}
      {{- printf "%s" (include "sch.names.fullCompName" (list . $compName)) | lower | trunc 63 -}}
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
        {{- $compName := include "gateway.get-name-or-use-default" (list . "gw-defaultpriv-sa") -}}
        {{- printf "%s" (include "sch.names.fullCompName" (list . $compName)) | lower | trunc 63 -}}
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
  {{- if (.Values.global.dockerRegistryPrefix) -}}
      {{- $dockerRepo := ( tpl (.Values.global.dockerRegistryPrefix | toString ) . ) | trimSuffix "/" -}}
      {{- printf "%s/" $dockerRepo -}}
  {{- else if and (.Values.global.image) (.Values.global.image.repository) -}}
    {{- if tpl (.Values.global.image.repository | toString ) . -}}
        {{- $dockerRepo := ( tpl (.Values.global.image.repository | toString ) . ) | trimSuffix "/" -}}
        {{- printf "%s/" $dockerRepo -}}
    {{- else -}}
        {{- .Values.global.image.repository -}}
    {{- end -}}
  {{- else if (.Values.global.icpDockerRepo) -}}
    {{- if tpl (.Values.global.icpDockerRepo | toString ) . -}}
      {{- $dockerRepo := ( tpl (.Values.global.icpDockerRepo | toString ) . ) | trimSuffix "/" -}}
      {{- printf "%s/" $dockerRepo -}}
    {{- else -}}
      {{- .Values.global.icpDockerRepo -}}
    {{- end -}}
  {{- else -}}
    {{- required "Invalid configuration 'Values.global.image.repository' must be specified" "" -}}
  {{- end -}}
{{- end -}}

{{- define "gateway.icpDockerImageSecret" -}}
  {{- if (.Values.global.image) -}}
    {{- if (.Values.global.image.pullSecret) -}} {{- tpl (.Values.global.image.pullSecret | toString ) . -}} {{- end -}}
  {{- else if (.Values.global.imagePullSecretName ) }}
    {{- tpl (.Values.global.imagePullSecretName | toString ) . -}}
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