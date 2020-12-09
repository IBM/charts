{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}
{{- define "metric-ingestion-service.sizeData" -}}
hpa:
  size0:
    enabled: false
  size1:
    enabled: false
metric-ingestion:
  size0:
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 1000Mi
        cpu: 200m
  size1:
    resources:
      limits:
        memory: 3000Mi
        cpu: 1000m
      requests:
        memory: 2000Mi
        cpu: 200m
{{- end -}}

{{- define "metric-ingestion-service.comp.size.data" -}}
  {{- $root := (index . 0) -}}
  {{- $resName := (index . 1) -}}
  {{- $keyName := (index . 2) -}}
  {{- $sizeData := fromYaml (include "metric-ingestion-service.sizeData" .) -}}
  {{- $resData := index $sizeData $resName -}}
  {{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
  {{- $result := index $resSizeData $keyName -}}

  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
