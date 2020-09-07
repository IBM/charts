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


{{- include "sch.config.init" (list . "ibm-hdm-analytics-dev.sch.chart.config.values") -}}

{{ define "ibm-hdm-analytics-dev.aggregationcollaterservice.component.name" -}}
collater-aggregationservice
{{- end }}

{{ define "ibm-hdm-analytics-dev.aggregationcollaterservice.deployment.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.aggregationcollaterservice.component.name" . -}}
{{- $deploymentName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $deploymentName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.aggregationcollaterservice.service.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.aggregationcollaterservice.component.name" . -}}
{{- $serviceName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $serviceName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.aggregationcollaterservice.test.component.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.aggregationcollaterservice.component.name" . -}}
{{- $testCompName :=  printf "%s-test" $compName -}}
{{- $testCompName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.aggregationcollaterservice.test.name" -}}
{{- $testCompName := include "ibm-hdm-analytics-dev.aggregationcollaterservice.test.component.name" . -}}
{{- $testName := include "sch.names.fullCompName" (list . $testCompName) -}}
{{- $testName -}}
{{- end }}