# Licensed Materials - Property of IBM
# IBM Order Management Software (5725-D10)
# (C) Copyright IBM Corp. 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "om-chart.sch.chart.config.values" -}}
sch:
  chart:
    appName: {{ template "om-chart.fullname" . }}
    version: {{ .Chart.Version }}
    fullName: {{ .Chart.Name }}-{{ .Chart.Version }}
    labelType: "prefixed"
    metering:
      productName: {{ template "om-chart.metering.prodname" . }}
      productID: {{ template "om-chart.metering.prodid" . }}
      productVersion: {{ template "om-chart.metering.prodversion" . }}
{{- end -}}