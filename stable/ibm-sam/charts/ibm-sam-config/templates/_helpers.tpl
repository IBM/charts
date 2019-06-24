{{/* vim: set filetype=mustache: */}}

{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation
###############################################################################
*/}}

{{/*
This chart relies on some of the help functions which are defined in the
main chart _helpers.tpl file.
*/}}

{{/*
Create the fully qualified name of our various service containers.
We truncate at 63 chars because some Kubernetes name fields are limited to 
this (by the DNS naming spec).
*/}}
{{- define "config.name" -}}
{{- printf "%s-isamconfig" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the fully qualified name of the configuration service URL.
We truncate at 63 chars because some Kubernetes name fields are limited to 
this (by the DNS naming spec).
*/}}
{{- define "config.service.url" -}}
{{- printf "https://%s:9443/shared_volume" (printf "%s-isamconfig" .Release.Name | trunc 63 | trimSuffix "-") -}}
{{- end -}}

{{/*
The name of our persistent volume claim.
*/}}
{{- define "config.pvc.name" -}}
{{- if .Values.dataVolume.existingClaimName -}}
{{- printf "%s" .Values.dataVolume.existingClaimName -}}
{{- else }}
{{- printf "%s-pvc-cfg" .Release.Name -}}
{{- end }}
{{- end -}}

