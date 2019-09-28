{{- /*
********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
*  5737-H89, 5737-H64
*
* © Copyright IBM Corp. 2015, 2019  All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication, or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
********************************************************* {COPYRIGHT-END} ****

Chart specific kubernetes resource requests and limits
This file defines the various sizes which may be included in a container's spec
*/ -}}

{{- /*
`$chart.resources` will supply a resources definition based on the provided yaml
in the cem.resources.sizeData definition. Specify resources in the format:
service:
  size0|1:
      resources:
__Usage:__
resources:
{{ include "cem.resources.comp.size.data" (list . "component" "resour") | indent 10 }}
```
  */ -}}

{{- define "cem.resources.sizeData" -}}
normalizer:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
brokers:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 200Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 300Mi
        cpu: 1000m
      requests:
        memory: 200Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 200Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 300Mi
        cpu: 1000m
      requests:
        memory: 200Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 200Mi
        cpu: 250m
      requests:
        memory: 100Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 250m
cemusers:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 800Mi
        cpu: 1000m
      requests:
        memory: 600Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 800Mi
        cpu: 1000m
      requests:
        memory: 600Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 450Mi
        cpu: 250m
      requests:
        memory: 350Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 800Mi
        cpu: 500m
      requests:
        memory: 600Mi
        cpu: 250m
channelservices:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
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
        memory: 2000Mi
        cpu: 2000m
      requests:
        memory: 600Mi
        cpu: 500m
  size0_amd64:
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    resources:
      limits:
        memory: 2000Mi
        cpu: 2000m
      requests:
        memory: 600Mi
        cpu: 500m
  size0_ppc64le:
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    resources:
      limits:
        memory: 2000Mi
        cpu: 1000m
      requests:
        memory: 600Mi
        cpu: 250m
eventanalyticsui:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
eventpreprocessor:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
incidentprocessor:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
integrationcontroller:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
schedulingui:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
notificationprocessor:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 500m
      requests:
        memory: 200Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 1000m
      requests:
        memory: 350Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 300Mi
        cpu: 250m
      requests:
        memory: 200Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 450Mi
        cpu: 500m
      requests:
        memory: 350Mi
        cpu: 250m
rbs:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 1536Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 1536Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 1536Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 1536Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 1536Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 1536Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 250m
as:
  size0:
    enableHPA: false
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 100m
  size1:
    enableHPA: true
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 500m
  size0_amd64:
    enableHPA: false
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 100m
  size1_amd64:
    enableHPA: true
    resources:
      limits:
        memory: 1024Mi
        cpu: 1000m
      requests:
        memory: 100Mi
        cpu: 500m
  size0_ppc64le:
    enableHPA: false
    resources:
      limits:
        memory: 1024Mi
        cpu: 250m
      requests:
        memory: 100Mi
        cpu: 50m
  size1_ppc64le:
    enableHPA: true
    resources:
      limits:
        memory: 1024Mi
        cpu: 500m
      requests:
        memory: 100Mi
        cpu: 250m
{{- end -}}

{{- define "cem.resources.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "cem.resources.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}

{{- define "cem.resources.comp.hpa" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $sizeData := fromYaml (include "cem.resources.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData "enableHPA" -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
