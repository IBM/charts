{{- define "zookeeper.sizeData" -}}
size0:
  replicas: 1
  jvmArgs: "-Xms64M -Xmx128M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.1"
    limits:
      memory: "450Mi"
      cpu: "0.5" 
size1:
  replicas: 3
  jvmArgs: "-Xms64M -Xmx256M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.2"
    limits:
      memory: "450Mi"
      cpu: "1.0"
size0_amd64:
  replicas: 1
  jvmArgs: "-Xms64M -Xmx128M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.05"
    limits:
      memory: "450Mi"
      cpu: "0.25" 
size1_amd64:
  replicas: 3
  jvmArgs: "-Xms64M -Xmx256M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.1"
    limits:
      memory: "450Mi"
      cpu: "0.5"
size0_ppc64le:
  replicas: 1
  jvmArgs: "-Xms64M -Xmx128M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.05"
    limits:
      memory: "450Mi"
      cpu: "0.25" 
size1_ppc64le:
  replicas: 3
  jvmArgs: "-Xms64M -Xmx256M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.1"
    limits:
      memory: "450Mi"
      cpu: "0.5"
{{- end -}}
{{- define "zookeeper.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $keyName := (index . 1) -}}
{{- $sizeData := fromYaml (include "zookeeper.sizeData" .) -}}
{{- $envSizeData := index $sizeData $root.Values.global.environmentSize -}}
{{- $result := index $envSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}      
