{{- /*
Chart specific kubernetes resource requests and limits
This file defines the various sizes which may be included in a container's spec
*/ -}}

{{- define "redis.sizeData" -}}
server:
  size0:
    resources:
      requests:
        memory: 200Mi
        cpu: 50m
      limits:
        memory: 300Mi
        cpu: 500m
  size1:
    resources:
      requests:
        memory: 350Mi
        cpu: 200m
      limits:
        memory: 450Mi
        cpu: 1000m
sentinel:
  size0:
    resources:
      requests:
        memory: 200Mi
        cpu: 50m
      limits:
        memory: 300Mi
        cpu: 500m
  size1:
    resources:
      requests:
        memory: 350Mi
        cpu: 200m
      limits:
        memory: 450Mi
        cpu: 1000m
{{- end -}}

{{- define "redis.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "redis.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
