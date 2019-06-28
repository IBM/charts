{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Check if tag contains specific platform suffix and if not set based on kube platform
*/}}
{{- define "platform" -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "ppc64le" }}
  {{- end -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "amd64" }}
  {{- end -}}
{{- end -}}


{{/*
Return arch based on kube platform
*/}}
{{- define "arch" -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
{{- end -}}

{{/*
Return number of replicas based on .Values.resources.gpu and .Values.ddl.gpuPerHost values.
*/}}
{{- define "workerCount" -}}
  {{- if and .Values.ddl.enabled (ne (int .Values.resources.gpu) 0)  (ne (int .Values.ddl.gpuPerHost) 0)}}
  {{- print (div (add .Values.resources.gpu .Values.ddl.gpuPerHost -1)  .Values.ddl.gpuPerHost) }}
  {{- else if and .Values.paiDistributed.mode (ne (int .Values.resources.gpu) 0)  (ne (int .Values.paiDistributed.gpuPerHost) 0)}}
  {{- print (div (add .Values.resources.gpu .Values.paiDistributed.gpuPerHost -1)  .Values.paiDistributed.gpuPerHost) }}
  {{- else }}
  {{- print "1" }}
  {{- end }}
{{- end -}}
