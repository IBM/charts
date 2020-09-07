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

{{- define "grafana.sizeData" -}}
grafana:
  size0:
    resources:
      requests:
        memory: "256Mi"
        cpu: "0.2"
      limits:
        memory: "1024Mi"
        cpu: "1.0"
  size1:
    resources:
      requests:
        memory: "1024Mi"
        cpu: "0.7"
      limits:
        memory: "2048Mi"
        cpu: "1.0"
{{- end -}}

{{- define "grafana.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "grafana.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
