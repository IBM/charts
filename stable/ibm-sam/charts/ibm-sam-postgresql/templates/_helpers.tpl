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
The full name for this chart.  We need to truncate the length of the name due 
to restrictions in the DNS.
*/}}

{{- define "postgresql.name" -}}
{{- printf "%s-isampostgresql" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Our postgresql database details
*/}}

{{- define "postgresql.dbname" -}}
{{- printf "isam" -}}
{{- end -}}

{{- define "postgresql.dbuser" -}}
{{- printf "isam" -}}
{{- end -}}

{{- define "postgresql.port" -}}
{{- printf "5432" -}}
{{- end -}}

