{{- /*
Config file for SCH (Shared Configurable Helpers)

sch<x.y.z>/_config.tpl is the config file sch. In addition a given
chart can specify additional values and/or override values via defined 
yaml structure passed during "sch.config.init' (see below). 
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- /*
"sch.config.version" contains the version information and tillerVersion constraint
for this version of the Shared Configurable Helpers.
*/ -}}
{{- define "sch.config.version" -}}
version: "1.0.0"
tillerVersion: ">=2.6.0"
requires:
  - "templates/sch-2.6.0/_utils.tpl"
{{- end -}}

{{- /*
"sch.config.values" contains the default configuration values used by
the Shared Configurable Helpers.

To override any of these values, modify the templates/_sch-chart-config.tpl file 
*/ -}}
{{- define "sch.config.values" -}}
sch:
  chart:
    appName: ""
  names:
    fullName:
      maxLength: 63
      releaseNameTruncLength: 42
      appNameTruncLength: 20
    fullCompName:
      maxLength: 63
      releaseNameTruncLength: 36
      appNameTruncLength: 13
      compNameTruncLength: 12
    statefulSetName:
      maxLength: 33
      releaseNameTruncLength: 15
      appNameTruncLength: 7
      compNameTruncLength: 9
    volumeClaimTemplateName:
      maxLength: 63
      possiblePrefix: "glusterfs-dynamic-"
      claimNameTruncLength: 7
    persistentVolumeClaimName:
      maxLength: 63
      possiblePrefix: "glusterfs-dynamic-"
      releaseNameTruncLength: 18
      appNameTruncLength: 13
      claimNameTruncLength: 12
{{- end -}}

{{- /*
"sch.chart.default.config.values" contains a default configuration values used by
the Shared Configurable Helpers if not chart specific override file exists.

To override any of these values, modify the templates/_sch-chart-config.tpl file
with define of "sch.chart.config.values" 
*/ -}}
{{- define "sch.chart.default.config.values" -}}
sch:
  chart:
    appName: ""
{{- end -}}


{{- /*
"sch.config.init" will merge the sch config and override into the root context (aka "dot", ".")

Uses:
  - "sch.utils.getItem"

Parameters input as an array of one values:
  - the root context (required)
  - "sch.chart.config.values" (optional) if defined by the chart, will default to use defined "sch.chart.default.config.values"

Any template in which uses sch should have the following at the begin of the template.

Usage:
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
or 
{{- include "sch.config.init" (list .) -}}

*/ -}}
{{- define "sch.config.init" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $schChartConfigName := (include "sch.utils.getItem" (list $params 1 "sch.chart.default.config.values")) -}}
  {{- $schChartConfig := fromYaml (include $schChartConfigName $root) -}}
  {{- $schConfig := fromYaml (include "sch.config.values" $root) -}}
  {{- $valuesMetadata := dict "valuesMetadata" (fromYaml ($root.Files.Get "values-metadata.yaml")) -}}
  {{- $_ := merge $root $schChartConfig -}}
  {{- $_ := merge $root $schConfig -}}
  {{- $_ := merge $root $valuesMetadata -}}
{{- end -}}


