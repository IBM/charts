{{/* vim: set filetype=mustache: */}}
{{/*
Docker image name template
args: rootContext
args: image:
        name: ""
        tag: ""
*/}}
{{- define "discovery.operator.image" -}}
{{- $root := (index . 0) -}}
{{- $image := (index . 1 ) -}}
{{- if $root.Values.global.dockerRegistryPrefix -}}
{{- $root.Values.global.dockerRegistryPrefix | trimSuffix "/" }}/
{{- end -}}
{{- $image.name }}:{{ $image.tag -}}
{{- end -}}
