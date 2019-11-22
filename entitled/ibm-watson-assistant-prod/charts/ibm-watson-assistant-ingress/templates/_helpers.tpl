{{- define "assistant.ingress.store_service_name" -}}wcs-{{ .Release.Name }}{{- end -}}

{{- define "assistant.ingress.tooling_service_name" -}}{{ .Release.Name }}-ui{{- end -}}


{{- define "assistant.ingress.addonService.name" -}}
  {{- /* Just a bit more complicted and hopefully safer way to render "{ { .Release.Name } } -addon-assistant". Simulating the behavior of sch cart rendering the name */ -}}
  {{- include "assistant.ingress.addon.simulatedContext" (list . "addonSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .addonSimulatedContext "addon") }}
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

{{- define "assistant.ingress.addon.simulatedContext" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $keyForSimulatedContext := (include "sch.utils.getItem" (list $params 1 "result")) -}}

  {{- $addonSimulatedContext := dict }}
  {{- $defaultValues := (dict "global" (dict "appName" "addon") "addon" (dict  "version" "" "serviceId" "assistant") "schConfigName" "wcn-addon.sch.chart.config.values" ) }}
  {{- $_ := set $addonSimulatedContext        "Values"   (merge dict $root.Values $defaultValues) }}

  {{- $_ := set $addonSimulatedContext        "Release" $root.Release      }}
  {{- $_ := set $addonSimulatedContext        "Chart"   (dict "Name" "ibm-wcn-addon")  }}
  {{- include "assistant.ingress.sch.config.init" (list $addonSimulatedContext $addonSimulatedContext.Values.schConfigName) -}}
  {{- $_ := set $root $keyForSimulatedContext $addonSimulatedContext }}
{{- end -}}

# Assistant fix of possibly unused parameter:
#    global.sch.enabled:      {{ .Values.global.sch.enabled }}
#    global.image.repository: {{ .Values.global.image.repository }} is used by template in value of global.icpDockerRepo