{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}
{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}

{{- define "metric-trigger-service.sch.chart.config.values" -}}
sch:
  chart:
    appName: "metric-trigger-service"
    components:
      metrictriggerservice:
        name: "metrictriggerservice"
    labelType: "prefixed"
{{- end -}}

{{- define "metric-trigger-service.data" -}}
  metering:
    productName: "metric-trigger-service"
    productID: "1"
    productVersion: "1.0.0.0"
{{- end -}}

{{- define "root.data" -}}
{{- $chartList := (splitList "/charts/" .Template.Name) -}}
{{- $rootChartName := (index (splitList "/" (index $chartList 0)) 0) -}}
{{- $rootDataTemplate := printf "%s.%s" $rootChartName "data" -}}
{{- include $rootDataTemplate . -}}
{{- end -}}
