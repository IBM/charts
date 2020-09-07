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

{{ define "ibm-hdm-analytics-dev.trainer.component.name" -}}
trainer
{{- end }}

{{ define "ibm-hdm-analytics-dev.trainer.deployment.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.trainer.component.name" . -}}
{{- $deploymentName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $deploymentName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.trainer.service.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.trainer.component.name" . -}}
{{- $serviceName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $serviceName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.trainer.test.component.name" -}}
{{- $compName := include "ibm-hdm-analytics-dev.trainer.component.name" . -}}
{{- $testCompName :=  printf "%s-test" $compName -}}
{{- $testCompName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.trainer.test.name" -}}
{{- $testCompName := include "ibm-hdm-analytics-dev.trainer.test.component.name" . -}}
{{- $testName := include "sch.names.fullCompName" (list . $testCompName) -}}
{{- $testName -}}
{{- end }}

{{- define "ibm-hdm-analytics-dev.trainer.getCemusersUrl" -}}
  {{- $root := index . 0 -}}
  {{- $varName := index . 1 -}}
  {{- $releaseName := default $root.Release.Name (index . 2) -}}
  {{- $namespace := default $root.Release.Namespace (index . 3) -}}
  {{- $varTpl := index . 4 -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
- name: {{ $varName | quote }}
  value: {{ tpl $varTpl $root | quote }}
{{- end -}}
