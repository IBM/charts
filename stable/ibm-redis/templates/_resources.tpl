{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
*/}}
{{- /*
Chart specific kubernetes resource requests and limits
This file defines the various sizes which may be included in a container's spec
*/ -}}
{{- define "ibmRedis.sizeData" -}}
{{- $root := (index . 0) -}}
both:
  size0:
    replicas: 1
  size1:
    replicas: 3
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
  custom:
    resources:
{{ toYaml $root.Values.resources.server | indent 6 }}
sentinel:
  size0:
    resources:
      requests:
        memory: 25Mi
        cpu: 10m
      limits:
        memory: 200Mi
        cpu: 200m
  size1:
    resources:
      requests:
        memory: 25Mi
        cpu: 10m
      limits:
        memory: 200Mi
        cpu: 200m
  custom:
    resources:
{{ toYaml $root.Values.resources.sentinel | indent 6 }}
{{- end -}}

{{- define "ibmRedis.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "ibmRedis.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
