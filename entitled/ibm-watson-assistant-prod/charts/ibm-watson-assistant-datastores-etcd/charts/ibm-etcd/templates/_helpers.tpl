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
{{ template "sch.names.fullName" (list . ) }}.{{ .Release.Namespace }}.svc.{{ tpl .Values.clusterDomain . }}
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
	{{- if tpl .Values.auth.existingRootSecret . -}}
		{{- tpl .Values.auth.existingRootSecret . -}}
	{{- else -}}
		{{- template "sch.names.fullName" (list . ) -}}-root
	{{- end -}}
{{- end -}}

{{/*
  Evaluates if a var is set to true or not.
  Support not only bool values true/false but also
    strings "true"/"false" and templates like "{{ .Values.global.etcd.tsl.enabled }}"
  Usage: {{ if "datastore.boolConverter" (list .Values.tls.enabled .) }}
*/}}
{{- define "datastore.boolConverter" -}}
	{{- if typeIs "bool" (first .) -}}
		{{- if (first .) }}    VALUE_IS_BOOL_TRUE_THUS_GENERATING_NON_EMPTY_STRING {{- end -}}
	{{- else if typeIs "string" (first .) -}}
		{{- if eq "true" ( tpl (first .) (last .) )  }}VAULT_IS_STRING_AND_RENDERS_TO_TRUE_THUS_GENERATING_NON_EMPTY_STRING{{- end -}}
	{{- end -}}
{{- end -}}

{{/*
Create the name for the etcd3 tls secret.
*/}}
{{- define "etcd3.clientProtocol" -}}
	{{- if include "datastore.boolConverter" (list .Values.tls.enabled . ) -}}
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
{{- if .Values.rbac.existingServiceAccount -}}
{{- .Values.rbac.existingServiceAccount -}}
{{- else -}}
{{ include "sch.names.fullName" (list . ) }}-serviceaccount
{{- end -}}
{{- end -}}

{{- define "etcd3.rolebindingname" -}}
{{ include "sch.names.fullName" (list . ) }}-rolebinding
{{- end -}}

{{- define "etcd3.podAntiAffinity" -}}
{{- if or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable")) -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ include "sch.names.appName" (list .) }}
    topologyKey: "kubernetes.io/hostname"
{{- end -}}
{{- end -}}
