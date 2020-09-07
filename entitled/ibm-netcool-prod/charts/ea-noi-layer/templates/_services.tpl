{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{- include "sch.config.init" (list . "ea-noi-layer.sch.chart.config.values") -}}

{{- define "ea-noi-layer.ibm-hdm-analytics-dev.releaseAppCompName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $releaseName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $chartName := "ibm-hdm-analytics-dev" -}}
  {{- $appName := (include "sch.names.appName" (list $root)) -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 2 "")) -}}
  {{- $maxLength := (int (include "sch.utils.getItem" (list $params 3 "253"))) -}}
  {{- $releaseNameTruncLength := (int (include "sch.utils.getItem" (list $params 4 "253"))) -}}
  {{- $appNameTruncLength := (int (include "sch.utils.getItem" (list $params 5 "253"))) -}}
  {{- $compNameTruncLength := (int (include "sch.utils.getItem" (list $params 6 "253"))) -}}

  {{- $fullLengthResult := (printf "%s-%s-%s" $releaseName $chartName $compName) -}}
  {{- $fullLengthResult :=  include "sch.utils.withinLength" (list $root $fullLengthResult $maxLength) -}}

  {{- if $fullLengthResult -}}
    {{- $fullLengthResult | lower | trimSuffix "-" -}}
  {{- else -}}
    {{- $buildNameParms := (list) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" $releaseName "length" $releaseNameTruncLength) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" $chartName "length" $appNameTruncLength) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" $compName "length" $compNameTruncLength) -}}

    {{- $shortResult := print (include "sch.names.buildName" $buildNameParms) -}}
    {{- $shortResult | lower | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}


{{- define "ea-noi-layer.ibm-hdm-analytics-dev.fullCompName" }}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $releaseName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 2 "")) -}}

  {{/* $schBase values are defined in sch/_config.yaml and can be modified by chart in sch-chart-config.yaml*/}}
  {{- $schBase := dict "sch" (dict "names" (dict "fullCompName" (dict "maxLength" 253 "releaseNameTruncLength" 253 "appNameTruncLength" 253 "compNameTruncLength" 253))) -}}
  {{- $_ := merge $root $schBase -}}
  {{- $maxLength := (int ($root.sch.names.fullCompName.maxLength)) -}}
  {{- $releaseNameTruncLength := (int ($root.sch.names.fullCompName.releaseNameTruncLength)) -}}
  {{- $appNameTruncLength := (int ($root.sch.names.fullCompName.appNameTruncLength)) -}}
  {{- $compNameTruncLength := (int ($root.sch.names.fullCompName.compNameTruncLength)) -}}
  {{- include "ea-noi-layer.ibm-hdm-analytics-dev.releaseAppCompName" (list $root $releaseName $compName $maxLength $releaseNameTruncLength $appNameTruncLength $compNameTruncLength) -}}
{{- end -}}

{{ define "ea-noi-layer.ibm-hdm-analytics-dev.aggnormalizer.servname" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $releaseName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $compName := "normalizer-aggregationservice" }}
  {{- $serviceName := include "ea-noi-layer.ibm-hdm-analytics-dev.fullCompName" (list $root $releaseName $compName) -}}
{{- $serviceName -}}
{{- end }}

{{ define "ea-noi-layer.ibm-hdm-analytics-dev.trainer.servname" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $releaseName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $compName := "trainer" }}
  {{- $serviceName := include "ea-noi-layer.ibm-hdm-analytics-dev.fullCompName" (list $root  $releaseName $compName) -}}
{{- $serviceName -}}
{{- end }}
