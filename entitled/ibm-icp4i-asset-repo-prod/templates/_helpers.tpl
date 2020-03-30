{{/* vim: set filetype=mustache: */}}

{{/*
Generates a comma delimited list of nodes in the cluster
*/}}
{{- define "couchdb.seedlist" -}}
{{- include "sch.config.init" (list . "sch.chart.config.values") }}
{{- $podName := include "sch.names.fullCompName" (list . "couchdb") }}
{{- $headlessServiceName := include "sch.names.fullCompName" (list . "couchdb-headless") }}
{{- $nodeCount :=  min 5 .Values.couchdb.replicas | int }}
  {{- range $index0 := until $nodeCount -}}
    {{- $index1 := $index0 | add1 -}}
    couchdb@{{ $podName }}-{{ $index0 }}.{{ $headlessServiceName }}.{{ $.Release.Namespace }}.svc.{{ $.Values.couchdb.dns.clusterDomainSuffix }}{{ if ne $index1 $nodeCount }},{{ end }}
  {{- end -}}
{{- end -}}
