{{/* vim: set filetype=mustache: */}}

{{- define "stolon.clusterName" -}}
{{- $genName := printf "%s-%s" .Release.Name .Chart.Name -}}
{{- $name := default $genName (tpl .Values.clusterName . ) -}}
{{- printf $name -}}
{{- end -}}

{{/* Create the name of the service account to use */}}
{{- define "stolon.serviceAccountName" -}}
  {{- if tpl .Values.serviceAccount.name . -}}
    {{- tpl .Values.serviceAccount.name . -}}
  {{- else -}}
    {{- include "sch.names.fullName" (list .) -}}
  {{- end -}}
{{- end -}}

{{/*
   A helper template to support templated boolean values.
   Takes a value (and converts it into Boolean equivalent string value).
     If the value is of type Boolean, then false value renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.

  Usage: For keys like `tls.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.postgres.tls.enables }}"

  Usage in templates:
    Instead of direct value test `{{ if .Values.tls.enabled }}` one has to use {{ if include "ibm-postgresql.boolConvertor" (list .Values.tls.enabled . ) }}
*/}}
{{- define "ibm-postgresql.boolConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VALUE renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  A helper template to compute affinity for sts/deployments.
  Usage in templates:
  To generate affinities based on overriden values in `sentinel.affinity` use  `{{- include "ibm-postgresql.affinity" (list . .Values.sentinel.affinity) | indent 8 }}`
*/}}
{{- define "ibm-postgresql.affinity" -}}
  {{- $params   := . -}}
  {{- $root     := first $params -}}
  {{- $affinity := index $params 1 -}}

  {{- if $affinity -}}
    {{- if kindIs "string" $affinity -}}
      {{- tpl  $affinity $root -}}
    {{- else -}}
      {{- tpl ( $affinity | toYaml ) $root -}}
    {{- end -}}
  {{- else -}}
    {{- /* Affinity override is not specified using default sch arch based affinities */ -}}
    {{- include "sch.affinity.nodeAffinity" (list $root $root.sch.chart.nodeAffinity) -}}
  {{- end -}}
{{- end -}}




{{/* Extract from sch char for initialization of sch context but without strange metadata-checks */}}
{{- define "ibm-postgresql.sch.config.init" -}}
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

{{- define "ibm-postgresql.simulatedContext" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $keyForSimulatedContext := (include "sch.utils.getItem" (list $params 1 "result")) -}}

  {{- $postgresSimulatedContext := dict }}
  {{- $_ := set $postgresSimulatedContext        "Values"   (merge dict $root.Values)   }}
  {{- /*  Hacks needed to render "ibmPostgres.sch.chart.config.values" */ -}}
  {{- $_ := set $postgresSimulatedContext.Values "metering" ""                     }}
  {{- $_ := set $postgresSimulatedContext.Values "postgresPodSecurityContext" ""   }}

  {{- $_ := set $postgresSimulatedContext        "Release" $root.Release      }}
  {{- $_ := set $postgresSimulatedContext        "Chart"   (dict "Name" "ibm-postgres")  }}
  {{- include "ibm-postgresql.sch.config.init" (list $postgresSimulatedContext "ibmPostgres.sch.chart.config.values") -}}
  {{- $_ := set $root $keyForSimulatedContext $postgresSimulatedContext }}
{{- end -}}

{{/*
******************************************************************************************
******************************************************************************************
*** Some helper templates for people using ibm-postgresql chart as subchart
***   and want to get some object names (secrets, service)
*** (not 100% reliable, especially .Values.nameOverride is not supported out-of-the-box -)
******************************************************************************************
******************************************************************************************
*/}}

{{/*
  Gets names of the generated auth secrets (the secret with user and password to postgresql).
  Limitation: does not support nameOverride (key).
*/}}

{{- define "ibm-postgresql.auth.authSecretName" -}}
  {{- include "ibm-postgresql.simulatedContext" (list . "postgresSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .postgresSimulatedContext .postgresSimulatedContext.sch.chart.components.authSecret) -}}
{{- end -}}

{{- define "ibm-postgresql.tls.tlsSecretName" -}}
  {{- include "ibm-postgresql.simulatedContext" (list . "postgresSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .postgresSimulatedContext .postgresSimulatedContext.sch.chart.components.tlsSecret) -}}
{{- end -}}

{{- define "ibm-postgresql.svc.proxyServiceName" -}}
  {{- include "ibm-postgresql.simulatedContext" (list . "postgresSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .postgresSimulatedContext .postgresSimulatedContext.sch.chart.components.proxyService) -}}
{{- end -}}
