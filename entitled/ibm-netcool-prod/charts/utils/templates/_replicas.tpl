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

{{/*
Set Log Analysis replica count
*/}}
{{- define "noi.loganalysis.replicas" -}}
{{- $root := ( index . 0 ) -}}
{{- $replicas := ( index . 1 ) -}}
{{- if eq $root.Values.global.enableLogAnalysis false -}}
0
{{- else -}}
{{- $replicas -}}
{{- end -}}
{{- end -}}

{{/*
Set Impact replica count
*/}}
{{- define "noi.impact.replicas" -}}
{{- $root := ( index . 0 ) -}}
{{- $replicas := ( index . 1 ) -}}
{{- if eq $root.Values.global.enableImpact false -}}
0
{{- else -}}
{{- $replicas -}}
{{- end -}}
{{- end -}}
