{{/*********************************************************** {COPYRIGHT-TOP} ****
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
********************************************************* {COPYRIGHT-END} ****/}}

{{- define "cem.releasename" -}}
{{- printf "%s" .Release.Name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cem.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}

{{- define "cem.datalayer.contactPoints" }}
{{- range $index := until (.Values.global.cassandraNodeReplicas | int) }}{{if ne $index 0}},{{end}}"{{$.Release.Name}}-cassandra-{{ $index }}.{{$.Release.Name}}-cassandra.{{$.Release.Namespace}}.svc"{{- end}}
{{- end }}

{{- define "cem.mcm" }}
  {{- if or (eq .Values.productName "Event Management for IBM Multicloud Manager") (eq .Values.productName "IBM Cloud App Management for Multicloud Manager") }}
    {{- printf "%s" "true" }}
  {{- else }}
    {{- printf "%s" "false" }}
  {{- end }}
{{- end -}}

{{- define "cem.ingress.prefix" }}
  {{- if ne (include "cem.mcm" .) "true" }}
    {{- .Values.global.ingress.prefix }}
  {{- end }}
{{- end -}}

{{- define "cem.ingress.api.prefix" }}
  {{- if ne (include "cem.mcm" .) "true" }}
    {{- .Values.global.ingress.prefix }}
  {{- else -}}
    cem/
  {{- end }}
{{- end -}}

{{/*
    Try to avoid scheduling the pod on a node that is running an instance of a
    given pod type. Normally this is used to avoid scheduling two pods of the
    same type on a given node.

    Example:-
    {{ include "cem.affinity.resilience" (dict "root" . "comp" "COMP") }}
*/}}
{{- define "cem.affinity.resilience" -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: {{ .root.Values.global.affinity.podAntiAffinity.weight }}
    podAffinityTerm:
      topologyKey: {{ .root.Values.global.affinity.podAntiAffinity.topologyKey }}
      labelSelector:
        matchLabels:
          release: {{ .root.Release.Name }}
          app: {{ include "sch.names.appName" (list .root) | quote }}
          component: {{ .comp | quote }}
{{- end }}

{{/*
    Try to schedule the pod on a node that is running an instance of another
    pod type. An example of use would be to schedule an application server close
    to its database.

    Example where the other pod is in this application:-
    {{ include "cem.affinity.performance" (dict "root" . "comp" "OTHERCOMP") }}

    Example where the other pod is a different application ("comp" can
    be added if the other application has more than one component):-
    {{ include "cem.affinity.performance" (dict "root" . "app" "OTHERAPP") }}
*/}}
{{- define "cem.affinity.performance" -}}
podAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: {{ .root.Values.global.affinity.podAffinity.weight }}
    podAffinityTerm:
      topologyKey: {{ .root.Values.global.affinity.podAffinity.topologyKey }}
      labelSelector:
        matchLabels:
          release: {{ .root.Release.Name }}
{{- if (hasKey . "app") }}
          app: {{ .app | quote }}
{{- else }}
          app: {{ include "sch.names.appName" (list .root) | quote }}
{{- end }}
{{- if (hasKey . "comp") }}
          component: {{ .comp | quote }}
{{- end }}
{{- end -}}
