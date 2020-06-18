{{- define "assistant.ingress.store_service_name" -}}wcs-{{ .Release.Name }}{{- end -}}

{{- define "assistant.ingress.tooling_service_name" -}}{{ .Release.Name }}-ui{{- end -}}


{{- define "assistant.ibm-watson-gateway.affinities.nodeAffinity" -}}
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

{{- define "assistant.ingress.addonService.name" -}}
  {{- /* Just a bit more complicted and hopefully safer way to render "{ { .Release.Name } } -addon-assistant-gateway-svc". Simulating the behavior of sch chart rendering the service name */ -}}
  {{- include "assistant.ingress.addon.simulatedContext" (list . "addonSimulatedContext") }}
  {{- $svcName := include "gateway.get-name-or-use-default" (list .addonSimulatedContext "gateway-svc") }}
  {{- include "sch.names.fullCompName" (list .addonSimulatedContext $svcName) }}
{{- end -}}

{{/* Extract from sch char for initialization of sch context but without strange metadata-checks */}}
{{- define "assistant.ingress.sch.config.init" -}}
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

{{/* Define minimal context that can be used to render the sch config for ibm-watson-gateway chart */}}
{{- define "assistant.ingress.addon.minimalValues" -}}
global:
  appName: "addon"
addon:
  version: ""
  serviceId: "assistant"
metering:
  productName:    "IBM Watson Assistant for IBM Cloud Pak for Data"
  productID:      "ICP4D-addon-fa92c14a5cd74c31aab1616889cbe97a-assistant"
  productVersion: "1.4.2"
  productMetric: ""
  productChargedContainers: ""
  cloudpakName: ""
  cloudpakId: ""
  cloudpakVersion: ""
schConfigName: "gateway.sch.chart.config.values"
{{- end -}}

{{- define "assistant.ingress.addon.simulatedContext" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $keyForSimulatedContext := (include "sch.utils.getItem" (list $params 1 "result")) -}}

  {{- $addonSimulatedContext := dict }}
  {{- $values := fromYaml (include "assistant.ingress.addon.minimalValues" $root ) }}

  {{- $_ := set $addonSimulatedContext              "Values"        $values                             }}
  {{- $_ := set $addonSimulatedContext              "Release"       $root.Release                       }}
  {{- $_ := set $addonSimulatedContext              "Capabilities"  $root.Capabilities                  }}
  {{- $_ := set $addonSimulatedContext              "Chart"         ( dict "Name" "ibm-watson-gateway") }}
  {{- $_ := set $addonSimulatedContext              "Template"      $root.Template  }}

  {{- include "assistant.ingress.sch.config.init" (list $addonSimulatedContext $values.schConfigName) -}}
  {{- $_ := set $root $keyForSimulatedContext $addonSimulatedContext }}
{{- end -}}

# Assistant fix of possibly unused parameter:
#    global.sch.enabled:      {{ .Values.global.sch.enabled }}
