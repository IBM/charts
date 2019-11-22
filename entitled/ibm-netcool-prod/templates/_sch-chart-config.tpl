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
      productName: "IBM Netcool Operations Insight v1.6.0.1 on IBM Cloud private"
      productID: "4DBA2B5A269740CAAE5FECDAFE0568AA"
      productVersion: "1.6.0.1"
      productChargedContainers: "All"
    labelType: prefixed
{{- end -}}
{{- define "ibm-netcool-prod.data" -}}
  metering:
      productName: "IBM Netcool Operations Insight v1.6.0.1 on IBM Cloud private"
      productID: "4DBA2B5A269740CAAE5FECDAFE0568AA"
      productVersion: "1.6.0.1"
      productChargedContainers: "All"
{{- end -}}
