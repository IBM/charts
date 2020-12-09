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
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    metering:
      productName: "IBM Netcool Operations Insight"
      productID: "4dba2b5a269740caae5fecdafe0568aa"
      productVersion: "1.6.3"
      productChargedContainers: "All"
      productMetric: "MANAGED_VIRTUAL_SERVER"
      cloudpakName: "IBM Netcool Operations Insight Cloud Pak"
      cloudpakId: "4dba2b5a269740caae5fecdafe0568aa"
      cloudpakVersion: "1.6.3"
    labelType: prefixed
{{- end -}}
{{- define "ibm-netcool-prod.data" -}}
  metering:
      productName: "IBM Netcool Operations Insight"
      productID: "4dba2b5a269740caae5fecdafe0568aa"
      productVersion: "1.6.3"
      productChargedContainers: "All"
      productMetric: "MANAGED_VIRTUAL_SERVER"
      cloudpakName: "IBM Netcool Operations Insight Cloud Pak"
      cloudpakId: "4dba2b5a269740caae5fecdafe0568aa"
      cloudpakVersion: "1.6.3"
{{- end -}}

{{- define "parent.data" -}}
{{ $chartList := (splitList "/charts/" .Template.Name) }}
{{ $rootChartName := (index (splitList "/" (index $chartList 0)) 0) }}
{{ $rootDataTemplate := printf "%s.%s" $rootChartName "data"}}
{{ include $rootDataTemplate . }}
{{- end -}}
