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
{{- define "alert-trigger-service.sizeData" -}}
hpa:
  size0:
    enabled: false
  size1:
    enabled: false
alert-trigger:
  size0:
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 1000Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 3000Mi
        cpu: 1200m
      requests:
        memory: 2000Mi
        cpu: 700m
{{- end -}}

{{- define "alert-trigger-service.comp.size.data" -}}
  {{- $root := (index . 0) -}}
  {{- $resName := (index . 1) -}}
  {{- $keyName := (index . 2) -}}
  {{- $sizeData := fromYaml (include "alert-trigger-service.sizeData" .) -}}
  {{- $resData := index $sizeData $resName -}}
  {{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
  {{- $result := index $resSizeData $keyName -}}

  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
