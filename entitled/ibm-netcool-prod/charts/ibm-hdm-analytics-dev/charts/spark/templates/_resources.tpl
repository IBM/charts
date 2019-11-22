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
in the ibmeaspark.sizeData definition. Specify resources in the format:
service:
  size0|1:
      resources:
__Usage:__
resources:
{{ include "ibmeaspark.comp.size.data" (list . "component" "resour") | indent 10 }}
```
  */ -}}

{{- define "ibmeaspark.sizeData" -}}
sparkmaster:
  size0:
    resources:
      limits:
        memory: 488Mi
        cpu: 300m
      requests:
        memory: 244Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 2000Mi
        cpu: 1000m
      requests:
        memory: 1000Mi
        cpu: 500m
sparkslave:
  size0:
    resources:
      limits:
        memory: 3000Mi
        cpu: 2000m
      requests:
        memory: 3000Mi
        cpu: 1000m
  size1:
    resources:
      limits:
        memory: 8000Mi
        cpu: 4000m
      requests:
        memory: 2000Mi
        cpu: 2000m
sparktest:
  size0:
    resources:
      limits:
        memory: 500Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 500m
  size1:
    resources:
      limits:
        memory: 500Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 500m
{{- end -}}

{{- define "ibmeaspark.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "ibmeaspark.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
