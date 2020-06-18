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
  Usage: {{ if "etcd3.boolConvertor" (list .Values.tls.enabled .) }}
*/}}
{{- define "etcd3.boolConvertor" -}}
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
	{{- if include "etcd3.boolConvertor" (list .Values.tls.enabled . ) -}}
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
  {{- if tpl ( .Values.serviceAccount.name | toString ) . -}}
    {{-  tpl ( .Values.serviceAccount.name | toString ) . -}}
  {{- else -}}
    {{ include "sch.names.fullName" (list . ) }}-serviceaccount
  {{- end -}}
{{- end -}}

{{- define "etcd3.rolebindingname" -}}
{{ include "sch.names.fullName" (list . ) }}-rolebinding
{{- end -}}

{{/*
  Adds support for templated affinity
  i.e., .Values.affinity: "{ { include "umbrella-chart.affinity" . } }"
*/}}
{{- define "etcd3.affinityEtcd" -}}
  {{- $allParams := . }}
  {{- $root    := first . }}
  {{- $details := first (rest . ) }}
  {{- $_       := set $root "affinityDetails" $details -}}

  {{- if and $root.Values.affinityEtcd (eq $details.component "server") -}}
    {{- if kindIs "string" $root.Values.affinityEtcd -}}
      {{- tpl $root.Values.affinityEtcd $root -}}
    {{- else -}}
      {{- range $key, $value := $root.Values.affinityEtcd }}
{{ tpl $value $root }}
      {{- end }}
    {{- end -}}
  {{- else if $root.Values.affinity -}}
    {{/* To be backward compatible, we are looking for .Values.affinity before defaulting to sch chart labels */}}
    {{- if kindIs "string" $root.Values.affinity -}}
      {{- tpl $root.Values.affinity $root -}}
    {{- else -}}
      {{- tpl ( $root.Values.affinity | toYaml ) $root -}}
    {{- end -}}
  {{- else -}}
    {{- include "sch.affinity.nodeAffinity" (list $root $root.sch.chart.nodeAffinity) }}
  {{- end -}}
{{- end -}}

{{- define "etcd3.antiAffinity" -}}
  {{- if .Values.antiAffinity.policy -}}
    {{/* Accept a string or a template as the mode */}}
    {{- $antiAffinityPolicy := (tpl .Values.antiAffinity.policy .) -}}
    {{- if eq $antiAffinityPolicy "hard" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: {{ tpl (.Values.antiAffinity.topologyKey | toString ) . }}
    labelSelector:
      matchLabels:
{{ include "sch.metadata.labels.standard" (list . "server") | indent 8 }}
    {{- else if eq $antiAffinityPolicy "soft" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      topologyKey: {{ tpl .Values.antiAffinity.topologyKey . }}
      labelSelector:
        matchLabels:
{{ include "sch.metadata.labels.standard" (list . "server") | indent 10 }}
    {{- end }}
  {{- end -}}
{{- end -}}
