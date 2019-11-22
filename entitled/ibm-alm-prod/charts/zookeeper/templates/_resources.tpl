{{- define "zookeeper.sizeData" -}}
size0:
  jvmArgs: "-Xms64M -Xmx128M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.1"
    limits:
      memory: "450Mi"
      cpu: "0.5" 
size1:
  jvmArgs: "-Xms64M -Xmx256M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.2"
    limits:
      memory: "450Mi"
      cpu: "1.0"   
{{- end -}}
{{- define "zookeeper.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $keyName := (index . 1) -}}
{{- $sizeData := fromYaml (include "zookeeper.sizeData" .) -}}
{{- $envSizeData := index $sizeData $root.Values.global.environmentSize -}}
{{- $result := index $envSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}      