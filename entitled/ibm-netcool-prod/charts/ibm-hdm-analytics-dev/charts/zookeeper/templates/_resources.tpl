{{- /*
The following set of templates works like this:
A) If the parent chart has a template called "<parentChartName>.zookeeper.sizeData"
AND you set .Values.zookeeper.useParentSizeData to true
it will use whatever size data you have defined in <parentChartName>.zookeeper.sizeData.
If you set .Values.zookeeper.useParentSizeData to true and you don't
have a template called "<parentChartName>.zookeeper.sizeData", you'll get a render error

B) If you don't set .Values.zookeeper.useParentSizeData at all, or you set it to false
or some other value, it will just use the zookeeper subchart's cem.resources.sizeData

You can use new sizes of your own creation that don't exist in the
zookeeper subchart's zookeeper.sizeData; you can also overwrite
the ones that do exist in zookeeper.sizeData.

*/ -}}

{{- define "zookeeper.getParentChart" -}}
{{ $chartList := (splitList "/charts/" .Template.Name) }}
{{ $rootChartName := (index (splitList "/" (index $chartList 0)) 0) | trim }}
{{ printf "%s" $rootChartName | trim }}
{{- end -}}

{{- define "zookeeper.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $keyName := (index . 1) -}}
{{- $childSizeKey := "zookeeper.sizeData" -}}
{{- $childSizeData := fromYaml (include $childSizeKey . ) -}}
{{- if (hasKey $root.Values "useParentSizeData") -}}
  {{- if (eq (toString $root.Values.useParentSizeData) "true") -}}
    {{- $parent := (include "zookeeper.getParentChart" $root) | trim -}}
    {{- $parentSizeKey := printf "%s.%s" $parent "zookeeper.sizeData"}}
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
      cpu: "0.1"
    limits:
      memory: "450Mi"
      cpu: "0.5" 
size1_amd64:
  replicas: 3
  jvmArgs: "-Xms64M -Xmx256M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.2"
    limits:
      memory: "450Mi"
      cpu: "1.0"
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
size0_s390x:
  replicas: 1
  jvmArgs: "-Xms64M -Xmx128M"
  resources:
    requests:
      memory: "350Mi"
      cpu: "0.05"
    limits:
      memory: "450Mi"
      cpu: "0.25" 
size1_s390x:
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
