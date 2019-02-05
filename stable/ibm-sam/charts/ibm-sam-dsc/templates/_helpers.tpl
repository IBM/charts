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
###############################################################################L
*/}}

{{/*
This chart relies on some of the help functions which are defined in the
main chart _helpers.tpl file.
*/}}

{{/*
The full name for this chart, qualified by the DSC type (i.e. primary or
secondary).  We need to truncate the length of the name due to restrictions
in the DNS.
*/}}

{{- define "dsc.name" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- printf "%s-isamdsc-%s" $root.Release.Name (index $params 1) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Our service names.  These names are limited to 15 characters.
*/}}

{{- define "dsc.service.name" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- printf "isamdsc-%s" (index $params 1) | trunc 15 | trimSuffix "-" -}}
{{- end -}}

{{- define "dsc.admin.service.name" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- printf "isamdscadmin-%s" (index $params 1) | trunc 15 | trimSuffix "-" -}}
{{- end -}}

{{- define "dsc.replica.service.name" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- printf "isamdscrep-%s" (index $params 1) | trunc 15 | trimSuffix "-" -}}
{{- end -}}
