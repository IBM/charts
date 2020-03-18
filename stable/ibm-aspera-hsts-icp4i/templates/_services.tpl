{{- include "sch.config.init" (list . "hsts.sch.chart.config.values") -}}

{{ define "hsts.values.masterId" -}}
  {{- include "sch.names.fullCompName" (list . .sch.chart.values.asperanode.masterId ) -}}
{{- end }}

{{ define "hsts.values.clusterId" -}}
  {{- coalesce .Values.asperanode.clusterId (include "sch.names.fullCompName" (list . .sch.chart.values.asperanode.clusterId )) -}}
{{- end }}

# Service specs
{{ define "hsts.services.aej" -}}
{{- $aejSuffix := .sch.chart.components.aej.compName -}}
{{- $aejName := include "sch.names.fullCompName" (list . $aejSuffix ) -}}
  {{- printf "%s:%d" $aejName 28000 -}}
{{- end }}

{{ define "hsts.services.redis" -}}
  {{-  if .Values.deployRedis }}
    {{- printf "%s-%s:%d" .Release.Name "redis-ha" 6379 -}}
  {{ else }}
    {{- printf "%s:%s" .Values.redisHost (toString .Values.redisPort) -}}
  {{ end }}
{{- end }}


{{ define "hsts.services.kafka" -}}
  {{- printf "%s:%s" .Values.aej.kafkaHost (toString .Values.aej.kafkaPort) -}}
{{- end }}

# Service hosts
{{ define "hsts.hosts.aej" -}}
  {{- $aejSuffix := .sch.chart.components.aej.compName -}}
  {{- $aejName := include "sch.names.fullCompName" (list . $aejSuffix ) -}}
  {{- printf "%s" $aejName -}}
{{- end }}

{{ define "hsts.hosts.redis" -}}
  {{-  if .Values.deployRedis }}
    {{- printf "%s-%s" .Release.Name "redis-ha-master" -}}
  {{ else }}
    {{- if (or (empty .Values.redisHost) (empty .Values.redisPort)) }}
      {{ fail "Configuration error: .Values.redisHost and .Values.redisPort required when not deploying redis" }}
    {{- end -}}
    {{- printf "%s" .Values.redisHost -}}
  {{ end }}
{{- end }}

{{ define "hsts.hosts.kafka" -}}
  {{- if (or (empty .Values.aej.kafkaHost) (empty .Values.aej.kafkaPort)) }}
    {{ fail "Configuration error: .Values.aej.kafkaHost and .Values.aej.kafkaPort required." }}
  {{- end -}}
  {{- printf "%s" .Values.aej.kafkaHost -}}
{{- end }}

# Service Ports
{{ define "hsts.ports.aej" -}}
  {{- printf "%d" 28000 -}}
{{- end }}

{{ define "hsts.ports.redis" -}}
  {{-  if .Values.deployRedis }}
    {{- printf "%d" 6379 -}}
  {{ else }}
    {{- printf "%s" (toString .Values.redisPort) -}}
  {{ end }}
{{- end }}

{{ define "hsts.ports.kafka" -}}
  {{- printf "%s" (toString .Values.aej.kafkaPort) -}}
{{- end }}

{{ define "hsts.locks.assemble" -}}
  {{- $params := . -}}
  {{- $context := index $params 0 -}}
  {{- $component := index $params 1 -}}
  {{ include "sch.names.fullCompName" (list $context (printf "%s-%s" $component $context.sch.chart.components.leaderElection) ) | quote }}
{{- end }}

{{ define "hsts.locks.stats" -}}
  {{- $params := (list . .sch.chart.components.stats.compName) -}}
  {{ include "hsts.locks.assemble" $params }}
{{- end }}

{{ define "hsts.locks.ascpSwarm" -}}
  {{- $params := (list . .sch.chart.components.ascpSwarm.compName) -}}
  {{ include "hsts.locks.assemble" $params }}
{{- end }}

{{ define "hsts.locks.nodedSwarm" -}}
  {{- $params := (list . .sch.chart.components.nodedSwarm.compName) -}}
  {{ include "hsts.locks.assemble" $params }}
{{- end }}

{{ define "hsts.locks.prometheusEndpoint" -}}
  {{- $params := (list . .sch.chart.components.prometheusEndpoint.compName) -}}
  {{ include "hsts.locks.assemble" $params }}
{{- end }}
