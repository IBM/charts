{{/* The following set of templates works like this: */}}
{{/* A) If the parent chart has a template called "<parentChartName>.old.kafka.sizeData" */}}
{{/* AND you set .Values.kafka.useParentSizeData to true */}}
{{/* it will use whatever size data you have defined in <parentChartName>.old.kafka.sizeData. */}}
{{/* If you set .Values.kafka.useParentSizeData to true and you don't */}}
{{/* have a template called "<parentChartName>.old.kafka.sizeData", you'll get a render error */}}
{{/* B) If you don't set .Values.kafka.useParentSizeData at all, or you set it to false */}}
{{/* or some other value, it will just use the kafka subchart's old.kafka.sizeData */}}
{{/* You can use new sizes of your own creation that don't exist in the */}}
{{/* kakfa subchart's old.kafka.sizeData; you can also overwrite the ones that do exist */}}
{{/* in the kafka subchart's old.kafka.sizeData. */}}
{{/* TEMPLATE TO FIND THE PARENT CHART */}}
{{- define "kafka.getParentChart" -}}
{{ $chartList := (splitList "/charts/" .Template.Name) }}
{{ $rootChartName := (index (splitList "/" (index $chartList 0)) 0) | trim }}
{{ printf "%s" $rootChartName | trim }}
{{- end -}}

{{/* FIND THE SIZE DATA BASED ON THE PARENT CHART */}}
{{- define "old.kafka.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $component := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $childSizeKey := "old.kafka.sizeData" -}}
{{- $childSizeData := fromYaml (include $childSizeKey . ) -}}
{{- if (hasKey $root.Values "useParentSizeData") -}}
  {{- if (eq (toString $root.Values.useParentSizeData) "true") -}}
    {{- $parent := (include "kafka.getParentChart" $root) | trim -}}
    {{- $parentSizeKey := printf "%s.%s" $parent "old.kafka.sizeData"}}
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
{{- define "old.kafka.sizeData" -}}
kafka:
  size0:
    replicas: 1
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size0_amd64:
    replicas: 1
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size0_ppc64le:
    replicas: 1
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.1"
      limits:
        memory: "800Mi"
        cpu: "0.5"
  size0_s390x:
    replicas: 1
    kafkaHeapOpts: "-Xms384M -Xmx384M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.1"
      limits:
        memory: "800Mi"
        cpu: "0.5"
  size1:
    replicas: 3
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.95"
      limits:
        memory: "1600Mi"
        cpu: "1.5"
  size1_amd64:
    replicas: 3
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.95"
      limits:
        memory: "1600Mi"
        cpu: "1.5"
  size1_ppc64le:
    replicas: 3
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.475"
      limits:
        memory: "1600Mi"
        cpu: "0.75"
  size1_s390x:
    replicas: 3
    kafkaHeapOpts: "-Xms1G -Xmx1G"
    resources:
      requests:
        memory: "1600Mi"
        cpu: "0.475"
      limits:
        memory: "1600Mi"
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
