{{- define "kafka.sizeData" -}}
kafka:
  size0:
    replicas: 1
    kafkaHeapOpts: "-Xms512M -Xmx512M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size1:
    replicas: 3
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.5"
      limits:
        memory: "1600Mi"
        cpu: "1.5" 
kafkarest:
  size0:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.2"
      limits:
        memory: "600Mi"
        cpu: "1.0" 
  size1:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.2"
      limits:
        memory: "600Mi"
        cpu: "1.0"
{{- end -}}
{{- define "kafka.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "kafka.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
