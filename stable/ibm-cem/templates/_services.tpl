{{/*
********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
*  5737-H89, 5737-H64
*
* © Copyright IBM Corp. 2015, 2019  All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication, or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
********************************************************* {COPYRIGHT-END} ****
There are some exceptions, but the general pattern is that the templates in
this file define micro-service urls.
These are used both in the application templates where they set BASEURL, and
in the configuration in _env.tpl.

Since these names are used for intra cluster communication they are of the form
http://{{ include "sch.names.fullCompName" (list . "serviceName") }}.{{ .Release.Namespace }}.svc:servicePort
The serviceName and servicePort must match those defined in the file within the
svc directory.

The cem.service.* templates can be used to extract the parts of the url.
For example the host of cem-users can be extracted with:

    {{ include "cem.service.host" (list . "cem.services.cemusers") }}
*/}}

{{- include "sch.config.init" (list . "cem.sch.chart.config.values") -}}

{{- define "cem.iproto" }}
{{- if .Values.global.internalTLS.enabled -}}
https
{{- else -}}
http
{{- end }}
{{- end }}


{{ define "cem.services.alertnotification" -}}
https://console-mp.us-south.alertnotification.cloud.ibm.com
{{- end }}

{{ define "cem.services.apm" -}}
http://{{ template "cem.releasename" . }}-amui.{{ .Release.Namespace }}.svc:3006
{{- end }}

{{ define "cem.services.brokers" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "brokers") }}.{{ .Release.Namespace }}.svc:6007
{{- end }}

{{/* The API URL is only used for external reference */}}
{{ define "cem.services.cemapi" -}}
{{- if ne .Values.global.ingress.apidomain "" -}}
https://{{ .Values.global.ingress.apidomain }}/api
{{- else if ne (.Values.global.ingress.port|toString) "443" -}}
https://{{ .Values.global.ingress.domain }}:{{ .Values.global.ingress.port }}/{{ include "cem.ingress.api.prefix" . }}api
{{- else -}}
https://{{ .Values.global.ingress.domain }}/{{ include "cem.ingress.api.prefix" . }}api
{{- end }}
{{- end }}

{{/* The following contains a trailing forward slash that can be removed in future versions post 2.3.0 (subject to issue 4908) */}}
{{ define "cem.services.cemusers" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "cem-users") }}.{{ .Release.Namespace }}.svc:6002/
{{- end }}

{{ define "cem.services.channelservices" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "channelservices") }}.{{ .Release.Namespace }}.svc:3091
{{- end }}

{{ define "cem.services.couchdb" -}}
http://{{ template "cem.releasename" . }}-couchdb.{{ .Release.Namespace }}.svc:5984
{{- end }}

{{ define "cem.services.datalayer" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "datalayer") }}.{{ .Release.Namespace }}.svc:10010
{{- end }}

{{ define "cem.services.eventpreprocessor" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "eventpreprocessor") }}.{{ .Release.Namespace }}.svc:3051
{{- end }}

{{ define "cem.services.incidentprocessor" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "incidentprocessor") }}.{{ .Release.Namespace }}.svc:6006
{{- end }}

{{/* The following must expand to a comma separated list of host:port (subject to issue 1194) */}}
{{ define "cem.services.kafkabrokers" -}}
{{ template "cem.releasename" . }}-kafka.{{ .Release.Namespace }}.svc:{{- if eq .Values.kafka.ssl.enabled true }}9093{{ else }}9092{{ end }}
{{- end }}

{{/* The following must expand to a json array of host:port (subject to issue 1194) */}}
{{ define "cem.services.kafkabrokers.json" -}}
["{{ template "cem.releasename" . }}-kafka.{{ .Release.Namespace }}.svc:{{- if eq .Values.kafka.ssl.enabled true }}9093{{ else }}9092{{ end }}"]
{{- end }}

{{ define "cem.services.kafkaadmin" -}}
http://{{ template "cem.releasename" . }}-kafka.{{ .Release.Namespace }}.svc:{{ .Values.global.kafka.kafkaRestInsecurePort }}
{{- end }}

{{ define "cem.services.normalizer" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "normalizer") }}.{{ .Release.Namespace }}.svc:3901
{{- end }}

{{ define "cem.services.notificationprocessor" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "notificationprocessor") }}.{{ .Release.Namespace }}.svc:6008
{{- end }}

{{ define "cem.services.integrationcontroller" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "integration-controller") }}.{{ .Release.Namespace }}.svc:6004
{{- end }}

{{ define "cem.services.regionrelay" -}}
https://cem-region-relay.opsmgmt.bluemix.net/
{{- end }}

{{ define "cem.services.metricrest" -}}
https://ea-api-REGION.opsmgmt.bluemix.net/
{{- end }}

{{ define "cem.services.rba" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "rba-rbs") }}.{{ .Release.Namespace }}.svc:3005
{{- end }}

{{ define "cem.services.rbaas" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "rba-as") }}.{{ .Release.Namespace }}.svc:3080
{{- end }}

{{ define "cem.services.redissecured" -}}
true
{{- end }}

{{ define "cem.services.redissentinelsvc" -}}
{{ template "cem.releasename" . }}-ibm-redis-sentinel-svc.{{ .Release.Namespace }}.svc
{{- end }}

{{ define "cem.services.redishost" -}}
{{ template "cem.releasename" . }}-ibm-redis-master-svc.{{ .Release.Namespace }}.svc
{{- end }}

{{ define "cem.services.schedulingui" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "scheduling-ui") }}.{{ .Release.Namespace }}.svc:3191
{{- end }}

{{ define "cem.services.uiserver" -}}
{{ include "cem.iproto" . }}://{{ include "sch.names.fullCompName" (list . "event-analytics-ui") }}.{{ .Release.Namespace }}.svc:3201
{{- end }}

{{/*
Ingress rule for a single host, used below
*/}}
{{ define "cem.ingress.rule" -}}
{{ $context :=  . | first -}}
{{ $prefix := . | rest| first -}}
{{ $service := . | rest | rest | first -}}
{{ $port := . | rest | rest | rest | first -}}
- path: /{{ include "cem.ingress.prefix" $context }}{{ $prefix }}
  backend:
    serviceName: {{ include "sch.names.fullCompName" (list $context $service) }}
    servicePort: {{ $port }}
{{- end }}

{{ define "cem.ingress.api.rule" -}}
{{ $context :=  . | first -}}
{{ $prefix := . | rest| first -}}
{{ $service := . | rest | rest | first -}}
{{ $port := . | rest | rest | rest | first -}}
- path: /{{ include "cem.ingress.api.prefix" $context }}{{ $prefix }}
  backend:
    serviceName: {{ include "sch.names.fullCompName" (list $context $service) }}
    servicePort: {{ $port }}
{{- end }}

{{/*
Use the ingress rule above for each service attached to ingress.
*/}}
{{ define "cem.ingress.uirules" -}}
{{ include "cem.ingress.rule" (list . "users/" "cem-users" 6002) }}
{{ include "cem.ingress.rule" (list . "chanl/" "channelservices" 3091) }}
{{ include "cem.ingress.rule" (list . "cemui/" "event-analytics-ui" 3201) }}
{{ include "cem.ingress.rule" (list . "integ/" "integration-controller" 6004) }}
{{ include "cem.ingress.rule" (list . "norml/" "normalizer" 3901) }}
{{ include "cem.ingress.rule" (list . "notif/" "notificationprocessor" 6008) }}
{{ include "cem.ingress.rule" (list . "sched/" "scheduling-ui" 3191) }}
{{ include "cem.ingress.rule" (list . "rbarb/" "rba-rbs" 3005) }}
{{- end }}
{{ define "cem.ingress.apirules" -}}
{{ include "cem.ingress.api.rule" (list . "api/eventPolicies/" "eventpreprocessor" 3051) }}
{{ include "cem.ingress.api.rule" (list . "api/eventPoliciesSpecification/" "eventpreprocessor" 3051) }}
{{ include "cem.ingress.api.rule" (list . "api/events/" "eventpreprocessor" 3051) }}
{{ include "cem.ingress.api.rule" (list . "api/incidentPolicies/" "incidentprocessor" 6006) }}
{{ include "cem.ingress.api.rule" (list . "api/incidentquery/" "incidentprocessor" 6006) }}
{{ include "cem.ingress.api.rule" (list . "api/notificationTemplates/" "channelservices" 3091) }}
{{ include "cem.ingress.api.rule" (list . "api/spec/incidentPolicies/" "incidentprocessor" 6006) }}
{{ include "cem.ingress.api.rule" (list . "api/v1/rba/" "rba-rbs" 3005) }}
{{ include "cem.ingress.api.rule" (list . "api-gateway/" "rba-rbs" 3005) }}
{{- end }}

{{/*
Micro services talk to each other directly, so they do not need ingress hosts.
If they need to talk via ingress entries for each ingress domain name used will
be added here.
*/}}
{{ define "cem.ingress.hostAlias" -}}
{{- end }}

{{ define "cem.service.protocol" -}}
{{ $context :=  . | first -}}
{{ $service :=  . | last -}}
{{ $fullurl := include $service $context -}}
{{ regexReplaceAll ":.*" $fullurl "" -}}
{{ end }}

{{ define "cem.service.host" -}}
{{ $context :=  . | first -}}
{{ $service :=  . | last -}}
{{ $fullurl := include $service $context -}}
{{ $lessproto := regexReplaceAll "^[[:alnum:]]*://" $fullurl "" -}}
{{ regexReplaceAll "[/:].*" $lessproto "" -}}
{{ end }}

{{ define "cem.service.port" -}}
{{ $context :=  . | first -}}
{{ $service :=  . | last -}}
{{ $fullurl := include $service $context -}}
{{ $lessproto := regexReplaceAll "^[[:alnum:]]*://[^/:]*:?" $fullurl "" -}}
{{ regexReplaceAll "/.*" $lessproto "" -}}
{{ end }}
