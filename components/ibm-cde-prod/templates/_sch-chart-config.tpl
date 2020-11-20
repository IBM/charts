{{/*
#+------------------------------------------------------------------------+
#| Licensed Materials - Property of IBM
#| IBM Cognos Products: Cognos Dashboard Embedded
#| (C) Copyright IBM Corp. 2019
#|
#| US Government Users Restricted Rights - Use, duplication or disclosure
#| restricted by GSA ADP Schedule Contract with IBM Corp.
#+------------------------------------------------------------------------+
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
{{- define "dde.sch.chart.config.values" -}}
sch:
  chart:
    appName: "DynamicDashboardEmbeddedService"
    shortName: "DDE"
    metering:
      productName: "dynamic-dashboard-embedded"
      productID: "dontknow-dde"
      productVersion: "0.1.0"
{{- end -}}
