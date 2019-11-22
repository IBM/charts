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
{{- end -}}
{{- define "cassandra.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $keyName := (index . 1) -}}
{{- $sizeData := fromYaml (include "cassandra.sizeData" .) -}}
{{- $envSizeData := index $sizeData $root.Values.global.environmentSize -}}
{{- $result := index $envSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
