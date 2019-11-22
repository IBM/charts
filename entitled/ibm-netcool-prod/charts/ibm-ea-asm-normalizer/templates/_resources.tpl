{{- define "ibm-ea-asm-normalizer.sizeData" -}}
hpa:
  size0:
    enabled: false
  size1:
    enabled: false
normalizerstreams:
  size0:
    kafkaReplicationFactor: 1
    kafkaMinInSyncReplicas: 1
    resources:
      limits:
        memory: 2000Mi
        cpu: 1000m
      requests:
        memory: 500Mi
        cpu: 500m
  size1:
    kafkaReplicationFactor: 3
    kafkaMinInSyncReplicas: 2
    resources:
      limits:
        memory: 4000Mi
        cpu: 1000m
      requests:
        memory: 1000Mi
        cpu: 1000m
mirrormaker:
  size0:
    resources:
      limits:
        memory: 2000Mi
        cpu: 1000m
      requests:
        memory: 500Mi
        cpu: 500m
  size1:
    resources:
      limits:
        memory: 4000Mi
        cpu: 1000m
      requests:
        memory: 1000Mi
        cpu: 1000m
{{- end -}}

{{- define "ibm-ea-asm-normalizer.comp.size.data" -}}
  {{- $root := (index . 0) -}}
  {{- $resName := (index . 1) -}}
  {{- $keyName := (index . 2) -}}
  {{- $sizeData := fromYaml (include "ibm-ea-asm-normalizer.sizeData" .) -}}
  {{- $resData := index $sizeData $resName -}}
  {{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
  {{- $result := index $resSizeData $keyName -}}

  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
