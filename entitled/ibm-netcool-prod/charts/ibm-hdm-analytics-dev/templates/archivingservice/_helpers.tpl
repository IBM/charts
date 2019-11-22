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

{{ define "ibm-hdm-analytics-dev.archivingservice.component.name" -}}
archivingservice
{{- end }}

{{ define "ibm-hdm-analytics-dev.archivingservice.deployment.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.archivingservice.component.name" . -}}
{{- $deploymentName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $deploymentName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.archivingservice.service.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.archivingservice.component.name" . -}}
{{- $serviceName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $serviceName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.archivingservice.test.component.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.archivingservice.component.name" . -}}
{{- $testCompName :=  printf "%s-test" $compName -}}
{{- $testCompName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.archivingservice.test.name" -}}
{{- $testCompName := include "ibm-hdm-analytics-dev.archivingservice.test.component.name" . -}}
{{- $testName := include "sch.names.fullCompName" (list . $testCompName) -}}
{{- $testName -}}
{{- end }}