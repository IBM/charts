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
        memory: 2000Mi
        cpu: 200m
  size1:
    kafkaReplicationFactor: 3
    kafkaMinInSyncReplicas: 2
    resources:
      limits:
        memory: 2000Mi
        cpu: 1000m
      requests:
        memory: 2000Mi
        cpu: 200m
mirrormaker:
  size0:
    resources:
      limits:
        memory: 2000Mi
        cpu: 2000m
      requests:
        memory: 2000Mi
        cpu: 200m
  size1:
    resources:
      limits:
        memory: 2000Mi
        cpu: 2000m
      requests:
        memory: 2000Mi
        cpu: 200m
jobs:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 3000m
      requests:
        memory: 300Mi
        cpu: 300m
  size1:
    resources:
      limits:
        memory: 300Mi
        cpu: 300m
      requests:
        memory: 300Mi
        cpu: 300m
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
