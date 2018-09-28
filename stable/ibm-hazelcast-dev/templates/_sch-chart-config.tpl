{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "hazelcast"
    components: 
      imdg:
        name: "imdg"
    metering:
      productName: "Hazelcast"
      productID: "Hazelcast_310_free_00000"
      productVersion: "3.10.5"
{{- end -}}

{{- define "statefulNames.globals.yaml" -}}
{{ $ssn := include "sch.names.statefulSetName" (list . .sch.chart.components.imdg.name) }}
statefulNames:
  globals:
    appName: {{ include "sch.names.appName" (list .) }}
    statefulSetName: {{ $ssn }}
{{- end -}}

{{- define "statefulNames.globals" -}}
{{- $v := fromYaml (include "statefulNames.globals.yaml" .) -}}
{{- $_ := merge . $v -}}
{{- end -}}
