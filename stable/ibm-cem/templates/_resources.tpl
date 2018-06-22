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
{{ include "ibmcemprod.comp.size.data" (list . "component" "resour") | indent 10 }}
```
  */ -}}

{{- define "ibmcemprod.sizeData" -}}
normalizer:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
brokers:
  size0:
    resources:
      limits:
        memory: 200Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 300Mi
        cpu: 1000m
      requests:
        memory: 200Mi
        cpu: 500m
cemusers:
  size0:
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 800Mi
        cpu: 1000m
      requests:
        memory: 600Mi
        cpu: 500m
channelservices:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
datalayer:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 800Mi
        cpu: 1000m
      requests:
        memory: 600Mi
        cpu: 500m
eventanalyticsui:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
eventpreprocessor:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
incidentprocessor:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
integrationcontroller:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
        limits:
          memory: 450Mi
          cpu: 1000m
        requests:
          memory: 350Mi
          cpu: 500m
schedulingui:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
notificationprocessor:
  size0:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
rbs:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 500m
as:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 500m
{{- end -}}

{{- define "ibmcemprod.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "ibmcemprod.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
