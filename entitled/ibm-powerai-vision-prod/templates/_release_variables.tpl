{{/* IBM_SHIP_PROLOG_BEGIN_TAG                                              */}}
{{/* *****************************************************************      */}}
{{/*                                                                        */}}
{{/* Licensed Materials - Property of IBM                                   */}}
{{/*                                                                        */}}
{{/* (C) Copyright IBM Corp. 2018. All Rights Reserved.                     */}}
{{/*                                                                        */}}
{{/* US Government Users Restricted Rights - Use, duplication or            */}}
{{/* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.      */}}
{{/*                                                                        */}}
{{/* *****************************************************************      */}}
{{/* IBM_SHIP_PROLOG_END_TAG                                                */}}
{{- /*
Release metering variables for ICP - these can be ignored for non-ICP environments.
*/ -}}
{{- define "vision-release-annotations" }}
annotations:
  productName: IBM PowerAI Vision
  productID: 5737-H10
  productVersion: {{ .Chart.AppVersion }}
  # This makes sure anytime the configmap changes, the pods will recreate
  checksum/config: {{ include (print $.Template.BasePath "/vision-config-map.yaml") . | sha256sum }}
{{- end }}

{{- /*
Standard labels - make sure to keep these in sync with the labels in vision-config-map.yaml
*/ -}}
{{- define "vision-standard-labels" }}
app: {{ template "shortname" . }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end }}