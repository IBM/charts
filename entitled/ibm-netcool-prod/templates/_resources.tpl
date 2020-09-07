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
in the ibmnoiprod.sizeData definition. Specify resources in the format:
service:
  size0|1:
      resources:
__Usage:__
resources:
{{ include "ibmnoiprod.comp.size.data" (list . "component" "resources") | indent 10 }}
```
  */ -}}

{{- define "ibmnoiprod.sizeData" -}}
nciserver:
  size0:
    resources:
      limits:
        memory: 2048Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 200m
  size1:
    resources:
      limits:
        memory: 2048Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 200m
openldap:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 500Mi
        cpu: 100m
  size1:
    resources:
      limits:
        memory: 2048Mi
        cpu: 1000m
      requests:
        memory: 1024Mi
        cpu: 100m
webgui:
  size0:
    resources:
      limits:
        memory: 2048Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 1000m
  size1:
    resources:
      limits:
        memory: 4096Mi
        cpu: 4000m
      requests:
        memory: 2048Mi
        cpu: 2000m
db2ese:
  size0:
    resources:
      limits:
        memory: 2000Mi
        cpu: 1000m
      requests:
        memory: 2000Mi
        cpu: 500m
  size1:
    resources:
      limits:
        memory: 4000Mi
        cpu: 1000m
      requests:
        memory: 2000Mi
        cpu: 500m
configurationShare:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 50m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 50m
ncoprimary:
  size0:
    resources:
      limits:
        memory: 2048Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 1000m
  size1:
    resources:
      limits:
        memory: 4096Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 2000m
ncobackup:
  size0:
    resources:
      limits:
        memory: 2048Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 1000m
  size1:
    resources:
      limits:
        memory: 4096Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 1000m
aggGate:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 500Mi
        cpu: 500m
  size1:
    resources:
      limits:
        memory: 2048Mi
        cpu: 2000m
      requests:
        memory: 1024Mi
        cpu: 1000m
proxy:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 128Mi
        cpu: 500m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 2000m
      requests:
        memory: 128Mi
        cpu: 1000m
impactgui:
  size0:
    resources:
      limits:
        memory: 2048Mi
        cpu: 1000m
      requests:
        memory: 1024Mi
        cpu: 200m
  size1:
    resources:
      limits:
        memory: 2048Mi
        cpu: 1000m
      requests:
        memory: 1024Mi
        cpu: 200m
preinstall:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 50m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 50m
testPod:
  size0:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 50m
  size1:
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 512Mi
        cpu: 50m
{{- end -}}

{{- define "ibmnoiprod.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "ibmnoiprod.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
