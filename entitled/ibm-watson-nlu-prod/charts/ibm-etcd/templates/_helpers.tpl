{{- include "sch.config.init" (list . "etcd.sch.chart.config.values") -}}
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

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create the FQDN of service
*/}}
{{- define "etcd3.fullservicename" -}}
{{ template "sch.names.fullName" (list . ) }}.{{ .Release.Namespace }}.svc
{{- end -}}

{{/*
Create the name for the etcd3 tls secret.
*/}}
{{- define "etcd3.tlsSecret" -}}
{{- if tpl .Values.tls.existingTlsSecret . -}}
		{{- tpl .Values.tls.existingTlsSecret . -}}
	{{- else -}}
		{{- template "sch.names.fullName" (list . ) -}}-tls
	{{- end -}}
{{- end -}}

{{/*
Create the name for the etcd3 tls secret.
*/}}
{{- define "etcd3.rootSecret" -}}
	{{- if .Values.auth.existingRootSecret -}}
		{{- .Values.auth.existingRootSecret -}}
	{{- else -}}
		{{- template "sch.names.fullName" (list . ) -}}-root
	{{- end -}}
{{- end -}}

{{/*
  Evaluates if the TLS is enabled or not.
  Support not only bool values true/false but also
    strings "true"/"false" and templates like "{{ .Values.global.etcd.tsl.enabled }}"
  Usage: {{ if "etcd.tls.enabled" (list .Values.tls.enabled .) }}
*/}}
{{- define "etcd3.tls.enabled" -}}
	{{- if typeIs "bool" (first .) -}}
		{{- if (first .) }}                            TLS_ENABLED_BOOL  {{- end -}}
	{{- else if typeIs "string" (first .) -}}
		{{- if eq "true" ( tpl (first .) (last .) )  }}TLS_ENABLED_STRING{{- end -}}
	{{- end -}}
{{- end -}}

{{/*
Create the name for the etcd3 tls secret.
*/}}
{{- define "etcd3.clientProtocol" -}}
	{{- if include "etcd3.tls.enabled" (list .Values.tls.enabled . ) -}}
		{{- print "https" -}}
	{{- else -}}
		{{- print "http" -}}
	{{- end -}}
{{- end -}}

{{/*
Create the name for the etcd3 tls secret.
*/}}
{{- define "etcd3.clientAuthOptions" -}}
{{- end -}}

{{- define "etcd3.rolename" -}}
{{ include "sch.names.fullName" (list . ) }}-role
{{- end -}}

{{- define "etcd3.serviceaccountname" -}}
{{- if and (not .Values.rbac.create) (.Values.rbac.existingServiceAccount) -}}
{{- .Values.rbac.existingServiceAccount -}}
{{- else -}}
{{ include "sch.names.fullName" (list . ) }}-serviceaccount
{{- end -}}
{{- end -}}

{{- define "etcd3.rolebindingname" -}}
{{ include "sch.names.fullName" (list . ) }}-rolebinding
{{- end -}}
