{{- /*
Chart specific kubernetes resource requests and limits
This file defines the various sizes which may be included in a container's spec
*/ -}}

{{- /*
`$chart.resources` will supply a resources definition based on the provided yaml
in the ibmcemprod.sizeData definition. Specify resources in the format:
service:
  size0|1:
      resources:
__Usage:__
resources:
{{ include "old.couchdb.comp.size.data" (list . "component" "resources") | indent 10 }}
```
  */ -}}

{{- define "old.couchdb.sizeData" -}}
couchdb:
  size0:
    replicas: 1
    resources:
      limits:
        memory: 500Mi
        cpu: 1000m
      requests:
        memory: 500Mi
        cpu: 200m
  size0_amd64:
    replicas: 1
    resources:
      limits:
        memory: 500Mi
        cpu: 1000m
      requests:
        memory: 500Mi
        cpu: 200m
  size0_ppc64le:
    replicas: 1
    resources:
      limits:
        memory: 500Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 100m
  size0_s390x:
    replicas: 1
    resources:
      limits:
        memory: 500Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 100m
  size1:
    replicas: 3
    resources:
      limits:
        memory: 2000Mi
        cpu: 8000m
      requests:
        memory: 2000Mi
        cpu: 1000m
  size1_amd64:
    replicas: 3
    resources:
      limits:
        memory: 2000Mi
        cpu: 8000m
      requests:
        memory: 2000Mi
        cpu: 1000m
  size1_ppc64le:
    replicas: 3
    resources:
      limits:
        memory: 2000Mi
        cpu: 4000m
      requests:
        memory: 2000Mi
        cpu: 500m
  size1_s390x:
    replicas: 3
    resources:
      limits:
        memory: 2000Mi
        cpu: 4000m
      requests:
        memory: 2000Mi
        cpu: 500m
{{- end -}}

{{- define "old.couchdb.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "old.couchdb.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
