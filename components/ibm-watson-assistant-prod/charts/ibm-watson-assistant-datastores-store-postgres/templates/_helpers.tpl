{{- define "assistant.postgres.secret_name" -}}
{{ .Release.Name }}-postgres-secret
{{- end -}}

{{/*
   A helper template to support templated boolean values.
   Takes a value (and converts it into Boolean equivalent string value).
     If the value is of type Boolean, then false value renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.

  Usage: For keys like `tls.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.postgres.tls.enables }}"

  Usage in templates:
    Instead of direct value test `{{ if .Values.tls.enabled }}` one has to use {{ if include "assistant.ibm-postgresql.boolConvertor" (list .Values.tls.enabled . ) }}
*/}}
{{- define "assistant.ibm-postgresql.boolConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VALUE renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{- define "assistant.ibm-postgres.affinity.nodeAffinity" -}}
  {{- $originalAffinitiesStr     := include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) -}}
  {{- $affinities                := fromYaml $originalAffinitiesStr -}}

  {{- /* Patch requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0] - that sch chard generated just with arch key with additional LabelSelectorRequirements is specified in umbrella chart */ -}}
  {{- $additionalRequirements    := .Values.global.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms.matchExpressions -}}
  {{- $tmpNodeSelectorTerms      := $affinities.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms -}}
  {{- $tmpFirstNodeSelectorTerm  := first $tmpNodeSelectorTerms -}}
  {{- $tmpMatchExpressions       := $tmpFirstNodeSelectorTerm.matchExpressions -}}

  {{- /* Append additional match expression keys */ -}}
  {{- $tmpDict := (dict "updatedMatchExpressions" $tmpMatchExpressions) -}}
  {{- range $additionalLabelSelectorRequirement := $additionalRequirements -}}
    {{- $_  := set $tmpDict "updatedMatchExpressions" ( append $tmpDict.updatedMatchExpressions $additionalLabelSelectorRequirement) -}}
  {{- end -}}

  {{- /* Modify the affinities in place */ -}}
  {{- $_ := set $tmpFirstNodeSelectorTerm "matchExpressions" $tmpDict.updatedMatchExpressions -}}
  {{- $affinities | toYaml -}}
{{- end -}}

{{/*
  Because of the cv-linter silliness, we have to copy the templates from "optional" chart ibm-postgresql (in case of provided postgres) here.
  The logic in WA ensured that the tempaltes are used only if ibm-postgresql is enabled, however static analysis in the linter is not strong enought to detect this.
  
  At least linter does not complain if the exactly SAME template is defined twice
*/}}

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


{{/* Define minimal context that can be used to render the sch config for ibm-postgres chart */}}
{{- define "assistant.ibm-postgresql.minimalValues" -}}
nameOverride: store-postgres

# The values below are faked values, as they do not influence how secret / service names are computed.
#   they are here just to be able to render "ibmPostgres.sch.chart.config.values" template ( a sch config for ibm-postgresql chart)
metering:
  productName:    "IBM Watson Assistant for IBM Cloud Pak for Data"
  productID:      "ICP4D-addon-fa92c14a5cd74c31aab1616889cbe97a-assistant"
  productVersion: "1.4.2"
  productMetric: ""
  productChargedContainers: ""
  cloudpakName: ""
  cloudpakId: ""
  cloudpakVersion: ""

securityContext:
  postgres:
    runAsUser: ""
  creds:
    runAsUser: ""
{{- end -}}


{{- define "ibm-postgresql.simulatedContext" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $keyForSimulatedContext := (include "sch.utils.getItem" (list $params 1 "result")) -}}

  {{- $postgresSimulatedContext := dict }}
  {{- $values := fromYaml (include "assistant.ibm-postgresql.minimalValues" $root ) }}

  {{- $_ := set $postgresSimulatedContext              "Values"        $values                             }}
  {{- $_ := set $postgresSimulatedContext              "Release"       $root.Release                       }}
  {{- $_ := set $postgresSimulatedContext              "Capabilities"  $root.Capabilities                  }}
  {{- $_ := set $postgresSimulatedContext              "Chart"         ( dict "Name" "ibm-postgres")       }}
  {{- $_ := set $postgresSimulatedContext              "Template"      $root.Template                      }}

  {{- include "ibm-postgresql.sch.config.init" (list $postgresSimulatedContext "ibmPostgres.sch.chart.config.values") -}}
  {{- $_ := set $root $keyForSimulatedContext $postgresSimulatedContext }}
{{- end -}}

{{- define "ibm-postgresql.svc.proxyServiceName" -}}
  {{- include "ibm-postgresql.simulatedContext" (list . "postgresSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .postgresSimulatedContext .postgresSimulatedContext.sch.chart.components.proxyService) -}}
{{- end -}}
