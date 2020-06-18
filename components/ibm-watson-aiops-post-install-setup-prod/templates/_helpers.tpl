{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/* ######################################## IMAGE NAME ######################################### */}}
{{- define "zeno.deploymentId" -}}
ibm-aiops---{{ .Values.global.zenServiceInstanceDisplayName }}
{{- end -}}
{{/* ######################################## IMAGE NAME ######################################### */}}

{{/* ######################################## INSTANCE NAME ######################################### */}}
{{- define "zeno.instanceNameRef" -}}
ibm-aiops---{instance_name}
{{- end -}}
{{/* ######################################## INSTANCE NAME  ######################################### */}}


{{/* ######################################## IMAGE NAME ######################################### */}}
{{- define "zeno.imageName" -}}
"{{ if .root.Values.global.dockerRegistryPrefix}}{{ trimSuffix "/" .root.Values.global.dockerRegistryPrefix }}/{{ end }}{{ .service.image.repository | default .service.image.name }}:{{ .service.image.tag }}"
{{- end -}}
{{/* ######################################## IMAGE NAME ######################################### */}}


{{/* ######################################## IMAGE AFFINITY ################################## */}}
{{- define "zeno.nodeAffinity" -}}
{{- if .Values.global.affinity -}}
{{ toYaml .Values.global.affinity }}
{{- else -}}
{{ include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
{{- end -}}
{{- end -}}
{{/* ######################################## IMAGE AFFINITY ################################## */}}


