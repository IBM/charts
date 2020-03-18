# Assembles the image name based on repository, name, tag
# Uses global image repository if the image repository is empty
#
# Params:
#   - list
#     - context (.)
#     - image repository
{{ define "hsts.image.assemble" -}}
  {{- $params := . -}}
  {{- $context := index $params 0 -}}
  {{- $imageRepository := index $params 1 -}}
  {{- $name := index $params 2 -}}
  {{- $tag := index $params 3 -}}
  {{- $repository := coalesce $imageRepository $context.Values.image.repository -}}
  {{ list $repository $name | join "/" | clean }}:{{ $tag }}
{{- end }}

{{ define "hsts.image.pullSecrets" -}}
  {{- $imageSecList := list -}}
  {{- if (.Values.image.pullSecret) }}
    {{- $imageSecList := append $imageSecList .Values.image.pullSecret -}}
  {{- end }}
{{ (dict "imagePullSecrets" $imageSecList) | toYaml  }}
{{- end }}

{{ define "hsts.image.httpProxy" -}}
  {{- $params := (list . .Values.httpProxy.image.repository .Values.httpProxy.image.name .Values.httpProxy.image.tag) -}}
  {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.asperanode" -}}
   {{- $params := (list . .Values.asperanode.image.repository .Values.asperanode.image.name .Values.asperanode.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.probe" -}}
   {{- $params := (list . .Values.probe.image.repository .Values.probe.image.name .Values.probe.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.stats" -}}
   {{- $params := (list . .Values.stats.image.repository .Values.stats.image.name .Values.stats.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.aej" -}}
   {{- $params := (list . .Values.aej.image.repository .Values.aej.image.name .Values.aej.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.nodedSwarmMember" -}}
   {{- $params := (list . .Values.nodedSwarmMember.image.repository .Values.nodedSwarmMember.image.name .Values.nodedSwarmMember.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.election" -}}
   {{- $params := (list . .Values.election.image.repository .Values.election.image.name .Values.election.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.swarm" -}}
   {{- $params := (list . .Values.swarm.image.repository .Values.swarm.image.name .Values.swarm.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.receiverSwarm" -}}
   {{- $params := (list . .Values.receiver.swarm.image.repository .Values.receiver.swarm.image.name .Values.receiver.swarm.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.firstboot" -}}
   {{- $params := (list . .Values.firstboot.image.repository .Values.firstboot.image.name .Values.firstboot.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.tcpProxy" -}}
   {{- $params := (list . .Values.tcpProxy.image.repository .Values.tcpProxy.image.name .Values.tcpProxy.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.loadbalancer" -}}
   {{- $params := (list . .Values.loadbalancer.image.repository .Values.loadbalancer.image.name .Values.loadbalancer.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.prometheusEndpoint" -}}
   {{- $params := (list . .Values.prometheusEndpoint.image.repository .Values.prometheusEndpoint.image.name .Values.prometheusEndpoint.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.utils" -}}
   {{- $params := (list . .Values.utils.image.repository .Values.utils.image.name .Values.utils.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}

{{ define "hsts.image.sch" -}}
   {{- $params := (list . .Values.sch.global.image.repository .Values.sch.image.name .Values.sch.image.tag) -}}
   {{ include "hsts.image.assemble" ($params) }}
{{- end }}
