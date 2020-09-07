{{/* TEMPLATE TO FIND THE PARENT CHART */}}
{{- define "cassandra.getParentChart" -}}
{{ $chartList := (splitList "/charts/" .Template.Name) }}
{{ $rootChartName := (index (splitList "/" (index $chartList 0)) 0) | trim }}
{{ printf "%s" $rootChartName | trim }}
{{- end -}}

{{/* FIND THE SIZE DATA BASED ON THE PARENT CHART */}}
{{- define "old.cassandra.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $keyName := (index . 1) -}}
{{- $childSizeKey := "old.cassandra.sizeData" -}}
{{- $childSizeData := fromYaml (include $childSizeKey . ) -}}
{{- if (hasKey $root.Values "useParentSizeData") -}}
  {{- if (eq (toString $root.Values.useParentSizeData) "true") -}}
    {{- $parent := (include "cassandra.getParentChart" $root) | trim -}}
    {{- $parentSizeKey := printf "%s.%s" $parent "old.cassandra.sizeData"}}
    {{- $parentSizeData := fromYaml (include $parentSizeKey . ) -}}
    {{- $sizeData := merge $parentSizeData $childSizeData -}}
    {{- $result := index $sizeData $root.Values.global.environmentSize $keyName -}}
    {{- toYaml $result | trimSuffix "\n" -}}
  {{- else -}}
    {{- $sizeData :=  $childSizeData -}}
    {{- $result := index $sizeData $root.Values.global.environmentSize $keyName -}}
    {{- toYaml $result | trimSuffix "\n" -}}
  {{- end -}}
{{- else -}}
  {{- $sizeData :=  $childSizeData -}}
  {{- $result := index $sizeData $root.Values.global.environmentSize $keyName -}}
  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
{{- end -}}

{{- define "old.cassandra.sizeData" -}}
size0:
  replicas: 1
  cassandraHeapSize: "2G"
  cassandraHeapNewSize: "512M"
  cassandraConcurrentCompactors: 2
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "6Gi"
      cpu: "1"
    limits:
      memory: "6Gi"
      cpu: "4"
size1:
  replicas: 3
  cassandraHeapSize: "8G"
  cassandraHeapNewSize: "2G"
  cassandraConcurrentCompactors: 4
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "16Gi"
      cpu: "4"
    limits:
      memory: "16Gi"
      cpu: "6"
size0_amd64:
  replicas: 1
  cassandraHeapSize: "2G"
  cassandraHeapNewSize: "512M"
  cassandraConcurrentCompactors: 2
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "6Gi"
      cpu: "1"
    limits:
      memory: "6Gi"
      cpu: "4"
size1_amd64:
  replicas: 3
  cassandraHeapSize: "8G"
  cassandraHeapNewSize: "2G"
  cassandraConcurrentCompactors: 4
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "16Gi"
      cpu: "4"
    limits:
      memory: "16Gi"
      cpu: "6"
size0_ppc64le:
  replicas: 1
  cassandraHeapSize: "2G"
  cassandraHeapNewSize: "512M"
  cassandraConcurrentCompactors: 2
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "6Gi"
      cpu: "0.5"
    limits:
      memory: "6Gi"
      cpu: "2"
size1_ppc64le:
  replicas: 3
  cassandraHeapSize: "8G"
  cassandraHeapNewSize: "2G"
  cassandraConcurrentCompactors: 4
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "16Gi"
      cpu: "2"
    limits:
      memory: "16Gi"
      cpu: "3"
size0_s390x:
  replicas: 1
  cassandraHeapSize: "2G"
  cassandraHeapNewSize: "512M"
  cassandraConcurrentCompactors: 2
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "6Gi"
      cpu: "0.5"
    limits:
      memory: "6Gi"
      cpu: "2"
size1_s390x:
  replicas: 3
  cassandraHeapSize: "8G"
  cassandraHeapNewSize: "2G"
  cassandraConcurrentCompactors: 4
  cassandraMemtableFlushWriters: 2
  resources:
    requests:
      memory: "16Gi"
      cpu: "2"
    limits:
      memory: "16Gi"
      cpu: "3"
{{- end -}}
