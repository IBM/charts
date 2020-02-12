{{/* vim: set filetype=mustache: */}}

{{/*
  Generate name of the service account to use.
  Notice generation of the default service account name is valid only in ibm-mongodb chart.
*/}}
{{- define "ibm-mongodb.serviceAccount.name" -}}
  {{- if tpl .Values.serviceAccount.name . -}}
    {{- tpl .Values.serviceAccount.name . -}}
  {{- else -}}
    {{- include "sch.names.fullName" (list .) -}}
  {{- end -}}
{{- end -}}


{{/*
   A helper templates to support templated boolean values.
   Takes a value (and converts it into Boolean equivalet string value).
     If the value is of type boolean, then if false renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.
     
  Usage: For keys like `auth.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.mongodb.auth.enables }}"
  
  Usage in templates:
    Instead of direct value test `{{ if .Values.auth.enabled }}` one has to use {{ if include "ibm-mongodb.boolConvertor" (list .Values.auth.enabled . ) }}
*/}}
{{- define "ibm-mongodb.boolConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VAULT renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Adds support for templated affinity
  i.e., .Values.affinity: "{ { include "umbrella-chart.affinity" . } }"
*/}}
{{- define "ibm-mongodb.affinityMongodb" -}}
  {{- if .Values.affinityMongodb -}}
    {{- if kindIs "string" .Values.affinityMongodb -}}
      {{- tpl .Values.affinityMongodb . -}}
    {{- else -}}
      {{- $root := . -}}
      {{- range $key, $value := .Values.affinityMongodb }}
{{ tpl $value $root }}
      {{- end }}
    {{- end -}}
  {{- else if .Values.affinity -}}
    {{/* To be backward compatible, we are looking for .Values.affinity before defaulting to sch chart labels */}}
    {{- .Values.affinity -}}
  {{- else -}}
    {{- include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
  {{- end -}}
{{- end -}}




{{/* Extract from sch char for initialization of sch context but without strange metadata-checks */}}
{{- define "ibm-mongodb.sch.config.init" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $schChartConfigName := (include "sch.utils.getItem" (list $params 1 "sch.chart.default.config.values")) -}}
  {{- $schChartConfig := fromYaml (include $schChartConfigName $root) -}}
  {{- $schConfig := fromYaml (include "sch.config.values" $root) -}}
  {{- $_ := merge $root $schChartConfig -}}
  {{- $_ := merge $root $schConfig -}}
  {{- /* appName and shortName are in $root by default and need to be forcefully overwritten if they exist */ -}}
  {{- if hasKey $schChartConfig.sch.chart "appName" }}
    {{- $_ := set $root.sch.chart "appName" $schChartConfig.sch.chart.appName }}
  {{- end }}
  {{- if hasKey $schChartConfig.sch.chart "shortName" }}
    {{- $_ := set $root.sch.chart "shortName" $schChartConfig.sch.chart.shortName }}
  {{- end }}
{{- end -}}

{{- define "ibm-mongodb.simulatedContext" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $keyForSimulatedContext := (include "sch.utils.getItem" (list $params 1 "result")) -}}

  {{- $mongoSimulatedContext := dict }}
  {{- $_ := set $mongoSimulatedContext        "Values"   (merge dict $root.Values)   }}
  {{- /*  Hacks needed to render "ibmMongodb.sch.chart.config.values"            */ -}}
  {{- $_ := set $mongoSimulatedContext.Values "metering"                ""           }}
  {{- $_ := set $mongoSimulatedContext.Values "securityContext" (dict "mongodb" (dict "fsGroup" "" "runAsUser" "" "runAsGroup" "") "creds" (dict "runAsUser" "")) }}
  {{- $_ := set $mongoSimulatedContext        "Release"      $root.Release           }}
  {{- $_ := set $mongoSimulatedContext        "Capabilities" $root.Capabilities      }}
  {{- $_ := set $mongoSimulatedContext        "Chart"   (dict "Name" "ibm-mongodb")  }}
  {{- include "ibm-mongodb.sch.config.init" (list $mongoSimulatedContext "ibmMongodb.sch.chart.config.values") -}}
  {{- $_ := set $root $keyForSimulatedContext $mongoSimulatedContext }}
{{- end -}}

{{/*
******************************************************************************************
******************************************************************************************
*** Some helper templates for people using ibm-mongodb chart as subchart 
***   and want to get some object names (secrets, service, statefullset) 
*** (not 100% reliable)
******************************************************************************************
******************************************************************************************
*/}}

{{/* 
  Gets names of the generated auth secret (the secret with user and password to Mongo.
  Limitation: does not support nameOverride (key).
*/}}

{{- define "ibm-mongodb.admin.secretName" -}}
  {{- include "ibm-mongodb.simulatedContext" (list . "mongoSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .mongoSimulatedContext .mongoSimulatedContext.sch.chart.components.authSecret) -}}
{{- end -}}

{{- define "ibm-mongodb.cert.secretName" -}}
  {{- include "ibm-mongodb.simulatedContext" (list . "mongoSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .mongoSimulatedContext .mongoSimulatedContext.sch.chart.components.tlsSecret) -}}
{{- end -}}

{{- define "ibm-mongodb.svc.fullName" -}}
  {{- include "ibm-mongodb.simulatedContext" (list . "mongoSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .mongoSimulatedContext .mongoSimulatedContext.sch.chart.components.headless) }}.{{ .Release.Namespace }}.svc.{{ tpl .Values.clusterDomain . }}
{{- end -}}

{{- define "ibm-mongodb.svc.statefulsetName" -}}
  {{- include "ibm-mongodb.simulatedContext" (list . "mongoSimulatedContext") }}
  {{- include "sch.names.statefulSetName" (list .mongoSimulatedContext  .mongoSimulatedContext.sch.chart.components.server) }}
{{- end -}}
