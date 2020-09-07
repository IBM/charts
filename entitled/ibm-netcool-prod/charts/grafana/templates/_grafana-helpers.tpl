{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2020 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{/*
When replicaCount is set to "environmentSizeDefault" then use 1 replica at size0
and 1 replicas at size1.
*/}}
{{- define "grafana.replicas" -}}
  {{- if eq .Values.global.environmentSize "size0" }}
    {{- printf "%d" 1 }}
  {{- else -}}
    {{- printf "%d" 1 }}
  {{- end -}}
{{- end }}

{{- define "grafana.getImageRepo" -}}
{{- if .Values.global.image.repository -}}
{{- printf "%s" ( trimSuffix "/" .Values.global.image.repository ) }}
{{- end -}}
{{- end -}}

{{/*
Sets the resources required for helm test pods and initContainers
*/}}
{{- define "grafana.minimalPodResources" -}}
requests:
  memory: "64Mi"
  cpu: "100m"
limits:
  memory: "64Mi"
  cpu: "100m"
{{- end -}}

{{- define "grafana.containerSecurityContext" -}}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: true
runAsUser: 1000
capabilities:
  drop:
  - ALL
{{- end -}}
