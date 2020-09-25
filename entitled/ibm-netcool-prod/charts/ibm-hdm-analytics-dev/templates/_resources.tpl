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
in the ibmeaprod.sizeData definition. Specify resources in the format:
service:
  size0|1:
      resources:
__Usage:__
resources:
{{ include "ibmeaprod.comp.size.data" (list . "component" "resour") | indent 10 }}
```
  */ -}}

{{- define "ibmeaprod.sizeData" -}}
inference:
  size0:
    resources:
      limits:
        memory: 1000Mi
        cpu: 200m
      requests:
        memory: 1000Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 1000Mi
        cpu: 100m
eventsqueryservice:
  size0:
    resources:
      limits:
        memory: 244Mi
        cpu: 200m
      requests:
        memory: 244Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 2400Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 100m
archivingservice:
  size0:
    resources:
      limits:
        memory: 244Mi
        cpu: 200m
      requests:
        memory: 244Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 1000Mi
        cpu: 100m
servicemonitorservice:
  size0:
    resources:
      limits:
        memory: 244Mi
        cpu: 200m
      requests:
        memory: 244Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 100m
policyregistryservice:
  size0:
    resources:
      limits:
        memory: 244Mi
        cpu: 200m
      requests:
        memory: 244Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 1000Mi
        cpu: 100m
ingestionservice:
  size0:
    resources:
      limits:
        memory: 244Mi
        cpu: 200m
      requests:
        memory: 244Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 1000Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 100m
trainer:
  size0:
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 1000Mi
        cpu: 300m
  size1:
    resources:
      limits:
        memory: 4000Mi
        cpu: 500m
      requests:
        memory: 1000Mi
        cpu: 300m
aggregationcollater:
  size0:
    resources:
      limits:
        memory: 768Mi
        cpu: 200m
      requests:
        memory: 768Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 2000Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 100m
aggregationnormalizer:
  size0:
    resources:
      limits:
        memory: 244Mi
        cpu: 200m
      requests:
        memory: 244Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 1000Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 100m
aggregationdedup:
  size0:
    resources:
      limits:
        memory: 244Mi
        cpu: 200m
      requests:
        memory: 244Mi
        cpu: 10m
  size1:
    resources:
      limits:
        memory: 1000Mi
        cpu: 500m
      requests:
        memory: 500Mi
        cpu: 100m
{{- end -}}

{{- define "ibmeaprod.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "ibmeaprod.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
