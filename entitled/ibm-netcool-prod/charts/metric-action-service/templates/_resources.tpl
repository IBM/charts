{{- define "metric-action-service.sizeData" -}}
hpa:
  size0:
    enabled: false
  size1:
    enabled: false
metricactionservice:
  size0:
    kafkaReplicationFactor: 3
    kafkaMinInSyncReplicas: 2
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 200m
  size1:
    kafkaReplicationFactor: 3
    kafkaMinInSyncReplicas: 2
    resources:
      limits:
        memory: 4000Mi
        cpu: 1000m
      requests:
        memory: 1000Mi
        cpu: 200m
{{- end -}}

{{- define "metric-action-service.comp.size.data" -}}
  {{- $root := (index . 0) -}}
  {{- $resName := (index . 1) -}}
  {{- $keyName := (index . 2) -}}
  {{- $sizeData := fromYaml (include "metric-action-service.sizeData" .) -}}
  {{- $resData := index $sizeData $resName -}}
  {{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
  {{- $result := index $resSizeData $keyName -}}

  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
