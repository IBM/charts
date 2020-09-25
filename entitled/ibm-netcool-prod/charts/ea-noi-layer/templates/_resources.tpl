{{- /*
********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
*  5737-H89, 5737-H64
*
* © Copyright IBM Corp. 2015, 2018  All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication, or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
********************************************************* {COPYRIGHT-END} ****

Chart specific kubernetes resource requests and limits
This file defines the various sizes which may be included in a container's spec
*/ -}}

{{- /*
`$chart.resources` will supply a resources definition based on the provided yaml
in the ibmeanoilaye.sizeData definition. Specify resources in the format:
service:
  size0|1:
      resources:
__Usage:__
resources:
{{ include "ibmeanoilayer.comp.size.data" (list . "component" "resour") | indent 10 }}
```
  */ -}}

{{- define "ibmeanoilayer.sizeData" -}}
noieagateway:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 200m
      requests:
        memory: 512Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 4096Mi
        cpu: 500m
      requests:
        memory: 2048Mi
        cpu: 100m
noiactionservice:
  size0:
    resources:
      limits:
        memory: 512Mi
        cpu: 200m
      requests:
        memory: 512Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 100m
initContainer:
  size0:
    resources:
      limits:
        memory: 512Mi
        cpu: 300m
      requests:
        memory: 512Mi
        cpu: 50m
  size1:
    resources:
      limits:
        memory: 512Mi
        cpu: 300m
      requests:
        memory: 512Mi
        cpu: 50m
{{- end -}}

{{- define "ibmeanoilayer.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "ibmeanoilayer.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
