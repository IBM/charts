{{- define "kafka.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $component := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $childSizeKey := "kafka.sizeData" -}}
{{- $childSizeData := fromYaml (include $childSizeKey . ) -}}
{{- if (hasKey $root.Values "useParentSizeData") -}}
  {{- if (eq (toString $root.Values.useParentSizeData) "true") -}}
    {{- $parent := (include "kafka.getParentChart" $root) | trim -}}
    {{- $parentSizeKey := printf "%s.%s" $parent "kafka.sizeData"}}
    {{- $parentSizeData := fromYaml (include $parentSizeKey . ) -}}
    {{- $sizeData := merge $parentSizeData $childSizeData -}}
    {{- $result := index $sizeData $component $root.Values.global.environmentSize $keyName -}}
    {{- toYaml $result | trimSuffix "\n" -}}
  {{- else -}}
    {{- $sizeData :=  $childSizeData -}}
    {{- $result := index $sizeData $component $root.Values.global.environmentSize $keyName -}}
    {{- toYaml $result | trimSuffix "\n" -}}
  {{- end -}}
{{- else -}}
  {{- $sizeData :=  $childSizeData -}}
  {{- $result := index $sizeData $component $root.Values.global.environmentSize $keyName -}}
  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
{{- end -}}
{{- define "kafka.sizeData" -}}
kafka:
  size0:
    replicas: 3
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size0_amd64:
    replicas: 3
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size0_ppc64le:
    replicas: 3
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.1"
      limits:
        memory: "800Mi"
        cpu: "0.5"
  size0_s390x:
    replicas: 3
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.1"
      limits:
        memory: "800Mi"
        cpu: "0.5"
  size1:
    replicas: 6
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.95"
      limits:
        memory: "2600Mi"
        cpu: "1.5"
  size1_amd64:
    replicas: 6
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.95"
      limits:
        memory: "2600Mi"
        cpu: "1.5"
  size1_ppc64le:
    replicas: 6
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.475"
      limits:
        memory: "2600Mi"
        cpu: "0.75"
  size1_s390x:
    replicas: 6
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.475"
      limits:
        memory: "2600Mi"
        cpu: "0.75"
kafkarest:
  size0:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.05"
      limits:
        memory: "600Mi"
        cpu: "1.0" 
  size0_amd64:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.05"
      limits:
        memory: "600Mi"
        cpu: "1.0" 
  size0_ppc64le:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.025"
      limits:
        memory: "600Mi"
        cpu: "0.5" 
  size0_s390x:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.025"
      limits:
        memory: "600Mi"
        cpu: "0.5" 
  size1:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.05"
      limits:
        memory: "600Mi"
        cpu: "1.0"
  size1_amd64:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.05"
      limits:
        memory: "600Mi"
        cpu: "1.0"
  size1_ppc64le:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.025"
      limits:
        memory: "600Mi"
        cpu: "0.5"
  size1_s390x:
    jvmArgs: "-Xms64M -Xmx200M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.025"
      limits:
        memory: "600Mi"
        cpu: "0.5"
{{- end -}}

{{- define "kafka.minInSyncReplicas" -}}
{{- if  eq .Values.global.environmentSize  "size1" -}}
  {{- printf "%d" 2 }}
{{- else -}}
  {{- printf "%d" 1 }}
{{- end -}}
{{- end -}}

{{- define "kafka.topicReplicationFactor" -}}
{{- if  eq .Values.global.environmentSize  "size1" -}}
  {{- printf "%d" 3 }}
{{- else -}}
  {{- printf "%d" 1 }}
{{- end -}}
{{- end -}}
