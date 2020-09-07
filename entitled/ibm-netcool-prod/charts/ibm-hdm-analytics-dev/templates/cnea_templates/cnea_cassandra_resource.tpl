{{- define "cassandra.sizeData" -}}
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
{{- end -}}
{{- define "cassandra.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $keyName := (index . 1) -}}
{{- $sizeData := fromYaml (include "cassandra.sizeData" .) -}}
{{- $envSizeData := index $sizeData $root.Values.global.environmentSize -}}
{{- $result := index $envSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
