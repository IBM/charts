{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
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
{{- define "insights.sch.chart.config.values" -}}
sch:
  chart:
    nodeAffinity:
{{ toYaml .Values.global.insights.nodeAffinity | indent 6 }}
    metering:
      productID: {{ tpl (.Values.global.insights.metering.productID    | toString ) . }}
      productName: {{ tpl (.Values.global.insights.metering.productName    | toString ) . }}
      productVersion: {{ tpl (.Values.global.insights.metering.productVersion    | toString ) . }}
      productMetric: {{ tpl (.Values.global.insights.metering.productMetric    | toString ) . }}
      productChargedContainers: {{ tpl (.Values.global.insights.metering.productChargedContainers    | toString ) . }}
      cloudpakName: {{ tpl (.Values.global.insights.metering.cloudpakName    | toString ) . }}
      cloudpakId: {{ tpl (.Values.global.insights.metering.cloudpakId    | toString ) . }}
      cloudpakVersion: {{ tpl (.Values.global.insights.metering.cloudpakVersion    | toString ) . }}
{{- end -}}