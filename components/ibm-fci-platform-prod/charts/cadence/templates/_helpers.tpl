{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cadence.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cadence.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cadence.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified component name from the full app name and a component name.
We truncate the full name at 63 - 1 (last dash) - len(component name) chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
and we want to make sure that the component is included in the name.
*/}}
{{- define "cadence.componentname" -}}
{{- $global := index . 0 -}}
{{- $component := index . 1 | trimPrefix "-" -}}
{{- printf "%s-%s" (include "cadence.fullname" $global | trunc (sub 62 (len $component) | int) | trimSuffix "-" ) $component | trimSuffix "-" -}}
{{- end -}}

{{/*
Call nested templates.
*/}}
{{- define "call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 }}
{{- $template := index . 2 }}
{{- include $template (dict "Chart" (dict "Name" $subchart) "Values" (index $dot.Values $subchart) "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

{{- define "cadence.frontend.internalPort" -}}
7933
{{- end -}}

{{- define "cadence.history.internalPort" -}}
7934
{{- end -}}

{{- define "cadence.matching.internalPort" -}}
7935
{{- end -}}

{{- define "cadence.worker.internalPort" -}}
7939
{{- end -}}

{{- define "cadence.persistence.driver" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.server.config.persistence $store -}}
{{- if $storeConfig.driver -}}
{{- $storeConfig.driver -}}
{{- else -}}
{{- required (printf "Please specify persistence driver for %s store" $store) $storeConfig.driver -}}
{{- end -}}
{{- end -}}

{{- define "cadence.persistence.sql.pluginName" -}}
{{- $global := index . 0 -}}
{{- $store := index . 1 -}}
{{- $storeConfig := index $global.Values.server.config.persistence $store -}}
{{- if $storeConfig.sql.pluginName -}}
{{- $storeConfig.sql.pluginName -}}
{{- else -}}
{{- required (printf "Please specify sql plugin for %s store" $store) $storeConfig.sql.host -}}
{{- end -}}
{{- end -}}

{{/*
Format a string map as a query string.
*/}}
{{- define "to-query" }}
{{- trimSuffix "&" (include "_to-query" .)  }}
{{- end }}

{{/*
Format a string map as a query string.
*/}}
{{- define "_to-query" }}
{{- range $key, $value := . -}}{{ $key }}={{ $value }}&{{- end -}}
{{- end }}
