{{/*
********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
*  5737-H89, 5737-H64
*
* © Copyright IBM Corp. 2015, 2018  All Rights Reserved.
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

{{ define "cem.services.alertnotification" -}}
https://edge-alert-notification.stage1.mybluemix.net/
{{- end }}

{{ define "cem.services.apm" -}}
http://{{ template "releasename" . }}-amui.{{ .Release.Namespace }}.svc:3000
{{- end }}

{{ define "cem.services.brokers" -}}
http://{{ include "sch.names.fullCompName" (list . "brokers") }}.{{ .Release.Namespace }}.svc:6007
{{- end }}

{{/* The API URL is only used for external reference */}}
{{ define "cem.services.cemapi" -}}
https://{{ .Values.global.ingress.domain }}/{{ .Values.global.ingress.prefix }}api
{{- end }}

{{ define "cem.services.cemusers" -}}
http://{{ include "sch.names.fullCompName" (list . "cem-users") }}.{{ .Release.Namespace }}.svc:6002
{{- end }}

{{ define "cem.services.channelservices" -}}
http://{{ include "sch.names.fullCompName" (list . "channelservices") }}.{{ .Release.Namespace }}.svc:3091
{{- end }}

{{ define "cem.services.couchdb" -}}
http://{{ template "releasename" . }}-couchdb.{{ .Release.Namespace }}.svc:5984
{{- end }}

{{ define "cem.services.datalayer" -}}
http://{{ include "sch.names.fullCompName" (list . "datalayer") }}.{{ .Release.Namespace }}.svc:10010
{{- end }}

{{ define "cem.services.eventpreprocessor" -}}
http://{{ include "sch.names.fullCompName" (list . "eventpreprocessor") }}.{{ .Release.Namespace }}.svc:3051
{{- end }}

{{ define "cem.services.incidentprocessor" -}}
http://{{ include "sch.names.fullCompName" (list . "incidentprocessor") }}.{{ .Release.Namespace }}.svc:6006
{{- end }}

{{/* The following must expand to a comma separated list of host:port (subject to issue 1194) */}}
{{ define "cem.services.kafkabrokers" -}}
{{ template "releasename" . }}-kafka.{{ .Release.Namespace }}.svc:{{- if eq .Values.kafka.ssl.enabled true }}9093{{ else }}9092{{ end }}
{{- end }}

{{/* The following must expand to a json array of host:port (subject to issue 1194) */}}
{{ define "cem.services.kafkabrokers.json" -}}
["{{ template "releasename" . }}-kafka.{{ .Release.Namespace }}.svc:{{- if eq .Values.kafka.ssl.enabled true }}9093{{ else }}9092{{ end }}"]
{{- end }}

{{ define "cem.services.kafkaadmin" -}}
{{ if (or (eq .Values.productName "IBM Cloud App Management") (eq .Values.productName "IBM Cloud App Management Advanced")) -}}
http://{{ template "releasename" . }}-kafka.{{ .Release.Namespace }}.svc:80
{{- else -}}
http://{{ template "releasename" . }}-kafka.{{ .Release.Namespace }}.svc:8080
{{- end }}
{{- end }}

{{ define "cem.services.normalizer" -}}
http://{{ include "sch.names.fullCompName" (list . "normalizer") }}.{{ .Release.Namespace }}.svc:3901
{{- end }}

{{ define "cem.services.notificationprocessor" -}}
http://{{ include "sch.names.fullCompName" (list . "notificationprocessor") }}.{{ .Release.Namespace }}.svc:6008
{{- end }}

{{ define "cem.services.integrationcontroller" -}}
http://{{ include "sch.names.fullCompName" (list . "integration-controller") }}.{{ .Release.Namespace }}.svc:6004
{{- end }}

{{ define "cem.services.regionrelay" -}}
https://cem-region-relay.opsmgmt.bluemix.net/
{{- end }}

{{ define "cem.services.metricrest" -}}
https://ea-api-REGION.opsmgmt.bluemix.net/
{{- end }}

{{ define "cem.services.rba" -}}
http://{{ include "sch.names.fullCompName" (list . "rba-rbs") }}.{{ .Release.Namespace }}.svc:3005
{{- end }}

{{ define "cem.services.rbaas" -}}
http://{{ include "sch.names.fullCompName" (list . "rba-as") }}.{{ .Release.Namespace }}.svc:3080
{{- end }}

{{ define "cem.services.redishost" -}}
{{ template "releasename" . }}-redis-master-svc.{{ .Release.Namespace }}.svc
{{- end }}

{{ define "cem.services.schedulingui" -}}
http://{{ include "sch.names.fullCompName" (list . "scheduling-ui") }}.{{ .Release.Namespace }}.svc:3191
{{- end }}

{{ define "cem.services.uiserver" -}}
http://{{ include "sch.names.fullCompName" (list . "event-analytics-ui") }}.{{ .Release.Namespace }}.svc:3201
{{- end }}

{{/*
Ingress rule for a single host, used below
*/}}
{{ define "ingress-rule" -}}
{{ $context :=  . | first -}}
{{ $prefix := . | rest| first -}}
{{ $service := . | rest | rest | first -}}
{{ $port := . | rest | rest | rest | first -}}
- path: /{{ $context.Values.global.ingress.prefix }}{{ $prefix }}
  backend:
    serviceName: {{ include "sch.names.fullCompName" (list $context $service) }}
    servicePort: {{ $port }}
{{- end }}

{{/*
Use the ingress rule above for each service attached to ingress.
*/}}
{{ define "ingress-rules" -}}
{{ include "ingress-rule" (list . "users" "cem-users" 6002) }}
{{ include "ingress-rule" (list . "chanl" "channelservices" 3091) }}
{{ include "ingress-rule" (list . "cemui" "event-analytics-ui" 3201) }}
{{ include "ingress-rule" (list . "integ" "integration-controller" 6004) }}
{{ include "ingress-rule" (list . "norml" "normalizer" 3901) }}
{{ include "ingress-rule" (list . "notif" "notificationprocessor" 6008) }}
{{ include "ingress-rule" (list . "sched" "scheduling-ui" 3191) }}
{{ include "ingress-rule" (list . "rbarb" "rba-rbs" 3005) }}
{{- end }}
{{ define "api-rules" -}}
{{ include "ingress-rule" (list . "api/eventPolicies" "eventpreprocessor" 3051) }}
{{ include "ingress-rule" (list . "api/eventPoliciesSpecification" "eventpreprocessor" 3051) }}
{{ include "ingress-rule" (list . "api/events" "eventpreprocessor" 3051) }}
{{ include "ingress-rule" (list . "api/incidentPolicies" "incidentprocessor" 6006) }}
{{ include "ingress-rule" (list . "api/incidentquery" "incidentprocessor" 6006) }}
{{ include "ingress-rule" (list . "api/spec/incidentPolicies" "incidentprocessor" 6006) }}
{{ include "ingress-rule" (list . "api/v1/rba" "rba-rbs" 3005) }}
{{ include "ingress-rule" (list . "api-gateway" "rba-rbs" 3005) }}
{{- end }}

{{/*
Micro services talk to each other directly, so they do not need ingress hosts.
If they need to talk via ingress entries for each ingress domain name used will
be added here.
*/}}
{{ define "ingress-host-alias" -}}
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
