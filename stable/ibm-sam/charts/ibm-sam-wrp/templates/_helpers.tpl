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
The full name for this chart, qualified by the instance number.  We need to
truncate the length of the name due to restrictions in the DNS.
*/}}

{{- define "wrp.name" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- printf "%s-isamwrp-%s" $root.Release.Name (index $params 1) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Our service names.
*/}}

{{- define "wrp.service.name" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- printf "isamwrp-%s-https" (index $params 1) -}}
{{- end -}}

{{- define "wrp.admin.service.name" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- printf "isamwrp-admin-%s" (index $params 1) -}}
{{- end -}}

